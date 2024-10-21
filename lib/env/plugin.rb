# =============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Environment.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Environment is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Environment. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Environment, please visit:
# https://github.com/openflighthpc/flight-env
# ==============================================================================
require_relative 'config'
require_relative 'errors'
require_relative 'shell'

require 'erb'
require 'fileutils'
require 'yaml'
require 'whirly'
require_relative 'patches/unicode-display_width'
require 'git'

module Env
  class Plugin
    FUNC_DELIMITER = begin
                       major, minor, patch =
                                     IO.popen("/bin/bash -c 'echo $BASH_VERSION'")
                                       .read.split('.')[0..2]
                                       .map(&:to_i)
                       (
                         major > 4 ||
                         major == 4 && minor > 3 ||
                         major == 4 && minor == 3 && patch >= 27
                       ) ? '%%' : '()'
                     end

    class << self
      def each(&block)
        all.each(&block)
      end

      def [](k)
        if k.start_with?(':')
          # git source
          dest_path = File.join(Config.tmpdir, 'repo')
          Git.clone(
            Config.plugin_repo,
            dest_path,
          )
          name = k.split(':').last
          name, version = name.split('=')
          all_in_path(dest_path).find {|p| p.name == name && (version.nil? || p.version == version) }
        elsif k.start_with?('/')
          # path source
          begin
            md = YAML.load_file(File.join(k,'metadata.yml'))
            t = Plugin.new(md, k)
            t.supports_host_arch? ? t : nil
          rescue
            nil
          end
        else
          name, version = k.split('=')
          all.find {|p| p.name == name && (version.nil? || p.version == version) }
        end.tap do |t|
          if t.nil?
            raise UnknownEnvironmentPluginError, "can't find environment plugin: #{k}"
          end
        end
      end

      def all_in_path(p)
        [].tap do |a|
          Dir[File.join(p,'*')].each do |d|
            begin
              md = YAML.load_file(File.join(d,'metadata.yml'))
              t = Plugin.new(md, d)
              a << t if t.supports_host_arch? && !t.disabled
            rescue
              nil
            end
          end
        end.sort {|a,b| [a.name, a.version] <=> [b.name, b.version] }
      end

      def all
        @plugins ||= [].tap do |a|
          Config.plugin_paths.each do |p|
            a.concat(all_in_path(p))
          end
        end.sort {|a,b| [a.name, a.version] <=> [b.name, b.version] }
      end
    end

    attr_reader :name
    attr_reader :summary
    attr_reader :url
    attr_reader :author
    attr_reader :arch
    attr_reader :disabled
    attr_reader :version
    attr_reader :conflicts

    def initialize(md, dir)
      @name = md[:name]
      @summary = md[:summary]
      @url = md[:url]
      @dir = dir
      @arch = md[:arch] || []
      @disabled = md[:disabled] || false
      @version = (md[:version] || 0).to_s
      @conflicts = md[:conflicts] || []
    end

    def supports_host_arch?
      if @arch.empty?
        true
      else
        @arch.include?(RbConfig::CONFIG['host_cpu'])
      end
    end

    def info_file
      @info_file ||= File.join(@dir, 'info.md')
    end

    def add(env)
      puts "Adding plugin #{Paint[self.name, :cyan]} to environment #{Paint[env.name, :magenta]}"
      if run_script(add_script, 'add', env)
        FileUtils.mkdir(File.join(env.path,'env-meta','plugins'))
        FileUtils.cp_r(@dir, File.join(env.path,'env-meta','plugins',self.name))
        puts "Plugin #{Paint[self.name, :cyan]} has been added to the #{Paint[env.name, :magenta]} environment"
      else
        log_file = File.join(
          build_cache_path(env.global?),
          "#{self.name}+#{env.name}.add.log"
        )
        raise EnvironmentOperationError, "Addition of #{self.name} plugin to #{env.name} environment failed; see: #{log_file}"
      end
    rescue
      old_stderr, old_stdout = $stderr, $stdout
      suppress_output { purge(name: name, global: global) rescue nil }
      raise
    end

    def remove(env)
      puts "Removing plugin #{Paint[self.name, :cyan]} from environment #{Paint[env.name, :magenta]}"
      plugin_path = File.join(env.path,'env-meta','plugins',self.name)
      if run_script(File.join(plugin_path,'remove.sh'), 'remove', env)
        FileUtils.rm_r(plugin_path, secure: true)
        puts "Plugin #{Paint[self.name, :cyan]} has been removed from the #{Paint[env.name, :magenta]} environment"
      else
        log_file = File.join(
          build_cache_path(env.global?),
          "#{self.name}+#{env.name}.remove.log"
        )
        raise EnvironmentOperationError, "Removal of #{self.name} plugin from #{env.name} environment failed; see: #{log_file}"
      end
    end

    def conflicts_with?(plugin)
      conflicts.include?(plugin.name)
    end

    private
    def depot_path(global)
      global ? Config.global_depot_path : Config.user_depot_path
    end

    def add_script
      File.join(@dir, "add.sh")
    end

    def build_cache_path(global)
      global ? Config.global_build_cache_path : Config.user_build_cache_path
    end

    def cache_path(global)
      global ? Config.global_cache_path : Config.user_cache_path
    end

    def run_fork(&block)
      Signal.trap('INT','IGNORE')
      rd, wr = IO.pipe
      pid = fork {
        rd.close
        Signal.trap('INT','DEFAULT')
        begin
          if block.call(wr)
            exit(0)
          else
            exit(1)
          end
        rescue Interrupt
          nil
        end
      }
      wr.close
      while !rd.eof?
        line = rd.readline
        if line =~ /^STAGE:/
          stage_stop
          @stage = line[6..-2]
          stage_start
        elsif line =~ /^ERR:/
          puts "== ERROR: #{line[4..-2]}"
        else
          puts " > #{line}"
        end
      end
      _, status = Process.wait2(pid)
      raise InterruptedOperationError, "Interrupt" if status.termsig == 2
      stage_stop(status.success?)
      Signal.trap('INT','DEFAULT')
      status.success?
    end

    def stage_start
      print "   > "
      Whirly.start(
        spinner: 'star',
        remove_after_stop: true,
        append_newline: false,
        status: Paint[@stage, '#2794d8']
      )
    end

    def stage_stop(success = true)
      return if @stage.nil?
      Whirly.stop
     puts "#{success ? "\u2705" : "\u274c"} #{Paint[@stage, '#2794d8']}"
    end

    def setup_bash_funcs(h, fileno)
      h["BASH_FUNC_flight_env_comms#{FUNC_DELIMITER}"] = <<EOF
() { local msg=$1
 shift
 if [ "$1" ]; then
 echo "${msg}:$*" 1>&#{fileno};
 else
 cat | sed "s/^/${msg}:/g" 1>&#{fileno};
 fi
}
EOF
      h["BASH_FUNC_env_err#{FUNC_DELIMITER}"] = "() { flight_env_comms ERR \"$@\"\n}"
      h["BASH_FUNC_env_stage#{FUNC_DELIMITER}"] = "() { flight_env_comms STAGE \"$@\"\n}"
#      h['BASH_FUNC_env_cat()'] = "() { flight_env_comms\n}"
#      h['BASH_FUNC_env_echo()'] = "() { flight_env_comms DATA \"$@\"\necho \"$@\"\n}"
    end

    def run_script(script, action, env)
      if File.exists?(script)
        global = env.global?
        FileUtils.mkdir_p(build_cache_path(global)) rescue nil
        FileUtils.mkdir_p(depot_path(global)) rescue nil
        if File.writable?(depot_path(global)) && File.writable?(build_cache_path(global))
          with_clean_env do
            run_fork do |wr|
              wr.close_on_exec = false
              setup_bash_funcs(ENV, wr.fileno)
              log_file = File.join(
                build_cache_path(global),
                "#{self.name}+#{env.name}.#{action}.log"
              )
              FileUtils.mkdir_p(build_cache_path(global))
              exec(
                {
                  'flight_ENV_ROOT' => depot_path(global),
                  'flight_ENV_CACHE' => cache_path(global),
                  'flight_ENV_BUILD_CACHE' => build_cache_path(global),
                },
                '/bin/bash',
                '-x',
                script,
                env.name,
                close_others: false,
                [:out, :err] => [log_file ,'w']
              )
            end
          end
        else
          raise EnvironmentOperationError, "unable to #{action} plugin to environment #{env.name} - permission denied"
        end
      else
        raise IncompletePluginError, "no #{action} script provided for plugin: #{self.name}"
      end
    end

    def suppress_output
      original_stderr, original_stdout = $stderr.clone, $stdout.clone
      $stderr.reopen(File.new('/dev/null', 'w'))
      $stdout.reopen(File.new('/dev/null', 'w'))
      yield
    ensure
      $stdout.reopen(original_stdout)
      $stderr.reopen(original_stderr)
    end

    def with_clean_env(&block)
      if Kernel.const_defined?(:OpenFlight) && OpenFlight.respond_to?(:with_standard_env)
        OpenFlight.with_standard_env { block.call }
      else
        msg = Bundler.respond_to?(:with_unbundled_env) ? :with_unbundled_env : :with_clean_env
        Bundler.__send__(msg) { block.call }
      end
    end
  end
end
