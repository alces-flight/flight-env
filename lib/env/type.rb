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

module Env
  class Type
    DEFAULT = 'default'

    class << self
      def each(&block)
        all.values.each(&block)
      end

      def [](k)
        all[k.to_sym].tap do |t|
          if t.nil?
            raise UnknownEnvironmentTypeError, "unknown environment type: #{k}"
          end
        end
      end

      def all
        @types ||=
          begin
            {}.tap do |h|
              Dir[File.join(Config.types_path,'*')].sort.each do |d|
                begin
                  md = YAML.load_file(File.join(d,'metadata.yml'))
                  h[md[:name].to_sym] = Type.new(md, d)
                rescue
                  nil
                end
              end
            end
          end
      end
    end

    attr_reader :name
    attr_reader :summary
    attr_reader :url
    attr_reader :author

    def initialize(md, dir)
      @name = md[:name]
      @summary = md[:summary]
      @url = md[:url]
      @dir = dir
    end

    def info_file
      @info_file ||= File.join(@dir, 'info.md')
    end

    def create(name: DEFAULT, global: false)
      puts "Creating environment #{Paint[self.name, :cyan]}@#{Paint[name, :magenta]}"
      if run_script(install_script(global), 'install', name, global)
        puts "Environment #{Paint[self.name, :cyan]}@#{Paint[name, :magenta]} has been created"
        Environment.new(self, name, global)
      else
        log_file = File.join(
          build_cache_path(global),
          "#{self.name}+#{name}.install.log"
        )
        raise EnvironmentOperationError, "Creation of environment #{self.name}@#{name} failed; see: #{log_file}"
      end
    rescue
      old_stderr, old_stdout = $stderr, $stdout
      suppress_output { purge(name: name, global: global) rescue nil }
      raise
    end

    def purge(name: DEFAULT, global: false)
      puts "Purging environment #{Paint[self.name, :cyan]}@#{Paint[name, :magenta]}"
      if run_script(purge_script(global), 'purge', name, global)
        puts "Environment #{Paint[self.name, :cyan]}@#{Paint[name, :magenta]} has been purged"
      else
        log_file = File.join(
          build_cache_path(global),
          "#{self.name}+#{name}.purge.log"
        )
        raise EnvironmentOperationError, "Purge of environment #{self.name}@#{name} failed; see: #{log_file}"
      end
    end

    def activator(name = DEFAULT, global = false)
      tmpl = ERB.new(File.read(eval_template('activate')))
      tmpl.result(render_binding(name, global))
    end

    def deactivator(name = DEFAULT, global = false)
      tmpl = ERB.new(File.read(eval_template('deactivate')))
      tmpl.result(render_binding(name, global))
    end

    private
    def render_binding(name, global = false)
      render_ctx = Module.new.class.tap do |eigen|
        eigen.define_method(:env_root) { global ? Config.global_depot_path : Config.user_depot_path }
        eigen.define_method(:env_name) { name }
        eigen.define_method(:env_global) { global }
      end
      render_ctx.instance_exec { binding }
    end

    def eval_template(phase)
      shell = Shell.type
      File.join(@dir, "#{phase}.#{shell.name}.erb").tap do |f|
        if ! File.exists?(f)
          phase_name = phase == 'activate' ? 'activator' : 'deactivator'
          raise EvaluatorError, "no #{phase_name} found for current shell: #{shell.name}"
        end
      end
    end

    def depot_path(global)
      global ? Config.global_depot_path : Config.user_depot_path
    end

    def purge_script(global)
      File.join(@dir, "#{global ? 'global' : 'user'}-purge.sh")
    end

    def install_script(global)
      File.join(@dir, "#{global ? 'global' : 'user'}-install.sh")
    end

    def build_cache_path(global)
      global ? Config.global_build_cache_path : Config.user_build_cache_path
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
      h['BASH_FUNC_flight_env_comms()'] = <<EOF
() { local msg=$1
 shift
 if [ "$1" ]; then
 echo "${msg}:$*" 1>&#{fileno};
 else
 cat | sed "s/^/${msg}:/g" 1>&#{fileno};
 fi
}
EOF
      h['BASH_FUNC_env_err()'] = "() { flight_env_comms ERR \"$@\"\n}"
      h['BASH_FUNC_env_stage()'] = "() { flight_env_comms STAGE \"$@\"\n}"
#      h['BASH_FUNC_env_cat()'] = "() { flight_env_comms\n}"
#      h['BASH_FUNC_env_echo()'] = "() { flight_env_comms DATA \"$@\"\necho \"$@\"\n}"
    end

    def run_script(script, action, name, global)
      if File.exists?(script)
        FileUtils.mkdir_p(build_cache_path(global)) rescue nil
        FileUtils.mkdir_p(depot_path(global)) rescue nil
        if File.writable?(depot_path(global)) && File.writable?(build_cache_path(global))
          Bundler.with_clean_env do
            run_fork do |wr|
              wr.close_on_exec = false
              setup_bash_funcs(ENV, wr.fileno)
              log_file = File.join(
                build_cache_path(global),
                "#{self.name}+#{name}.#{action}.log"
              )
              FileUtils.mkdir_p(build_cache_path(global))
              exec(
                {
                  'flight_ENV_ROOT' => depot_path(global),
                  'flight_ENV_CACHE' => build_cache_path(global),
                },
                '/bin/bash',
                '-x',
                script,
                name,
                close_others: false,
                [:out, :err] => [log_file ,'w']
              )
            end
          end
        else
          raise EnvironmentOperationError, "unable to #{action == 'install' ? 'create' : action} #{global ? 'global ' : ''}environment #{self.name}@#{name} - permission denied"
        end
      else
        raise IncompleteTypeError, "no #{global ? 'global ' : ''}#{action} script provided for type: #{self.name}"
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
  end
end
