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
require 'env/errors'

module Env
  class Environment
    DEFAULT = 'default'

    ACTUATOR_TEMPLATES = {
      'activate.bashrc' => File.read(File.join(__dir__, 'templates', 'activate.bashrc.erb')),
      'activate.tcshrc' => File.read(File.join(__dir__, 'templates', 'activate.tcshrc.erb')),
      'deactivate.bashrc' => File.read(File.join(__dir__, 'templates', 'deactivate.bashrc.erb')),
      'deactivate.tcshrc' => File.read(File.join(__dir__, 'templates', 'deactivate.tcshrc.erb')),
    }

    class << self
      def global_only=(val)
        @global_only = val
      end

      def active
        candidates =
          if ENV['flight_ENV_scope'] == 'user'
            user_envs
          elsif ENV['flight_ENV_scope'] == 'global'
            global_envs
          else
            all
          end
        fetch(ENV['flight_ENV_active'], candidates)
      end

      def each(&block)
        envs.each(&block)
      end

      def [](k)
        if !k.include?('@')
          env =
            fetch(k + "@#{DEFAULT}") ||
            envs.find{|e| e.to_s.start_with?(k + '@')}
        end
        (env || fetch(k)).tap do |e|
          if e.nil?
            raise NoSuchEnvironmentError, "unknown environment: #{k}"
          end
        end
      end

      def default
        Config.user_data.fetch(:default_environment) || begin
          unless Config.user_data.fetch(:system_default_opt_out)
            Config.data.fetch(:default_environment)
          end
        end
      end

      def remove_default(system)
        if system
          Config.data.delete(:default_environment)
          Config.save_data
        else
          Config.user_data.delete(:default_environment)
          Config.save_user_data
        end
      end

      def set_default(env_name, system)
        self[env_name].tap do |env|
          if system
            if env.global?
              Config.data.set(:default_environment, value: env.to_s)
              Config.save_data
            else
              raise SystemEnvironmentError, "user environment #{env_name} cannot be set as the system default"
            end
          else
            Config.user_data.set(:default_environment, value: env.to_s)
            Config.save_user_data
          end
        end
      end

      def system_default_opt_out(optout)
        Config.user_data.set(:system_default_opt_out, value: optout)
        Config.save_user_data
      end

      def create(name: DEFAULT, global: false)
        # if exists, error
        if (self[name] rescue nil)
          raise EnvironmentExistsError, "environment already exists: #{name}"
        end

        path = File.join(depot_path(global), name)
        Environment.new(name, path, global).init
      end

      def all
        @all ||= user_envs + global_envs
      end

      private
      def fetch(k, candidates = envs)
        candidates.find{|e| e.to_s == k}
      end

      def user_envs
        @user_envs ||= envs_for(Config.user_depot_path, false)
      end

      def global_envs
        @global_envs ||= envs_for(Config.global_depot_path, true)
      end

      def envs
        @global_only ? global_envs : all
      end

      def envs_for(path, global)
        [].tap do |a|
          Dir[File.join(path,'*')].sort.each do |d|
            next unless File.directory?(d) && File.directory?(File.join(d,'env-meta'))
            name = File.basename(d)
            a << Environment.new(name, d, global)
          end
        end
      end

      private
      def depot_path(global)
        global ? Config.global_depot_path : Config.user_depot_path
      end
    end

    attr_accessor :name, :global, :path

    def initialize(name, path, global = false)
      @name = name
      @path = path
      @global = global
    end

    def to_s
      @name
    end

    def plugins
      @plugins ||= [].tap do |a|
        Dir[File.join(@path, 'env-meta', 'plugins', '*')].each do |d|
          begin
            md = YAML.load_file(File.join(d,'metadata.yml'))
            a << Plugin.new(md, d)
          rescue
            nil
          end
        end
      end
    end
    
    def global?
      self.global
    end

    def activator
      File.read(template_for('activate'))
    rescue EvaluatorError
      ""
    end

    def deactivator
      File.read(template_for('deactivate'))
    rescue EvaluatorError
      ""
    end

    def init
      if File.directory?(File.join(@path, 'env-meta'))
        raise EnvironmentOperationError, "Environment at #{@path} already initialized."
      end
      stage "Initializing environment tree (#{name})" do
        FileUtils.mkdir_p(File.join(path, 'env-meta'))
        initialize_actuators
      end
    end        
    
    def purge
      if !File.directory?(File.join(@path, 'env-meta'))
        raise EnvironmentOperationError, "Environment at #{@path} is not initialized."
      end
      stage "Deleting environment tree (#{name})" do
        FileUtils.rm_r(@path, secure: true)
      end
    end

    private
    def template_for(phase)
      shell = Shell.type
      File.join(@path, 'env-meta', "#{phase}.#{shell.name}rc").tap do |f|
        if ! File.exists?(f)
          phase_name = phase == 'activate' ? 'activator' : 'deactivator'
          raise EvaluatorError, "no #{phase_name} found for current shell: #{shell.name}"
        end
      end
    end

    def stage(title, &block)
      print "   > "
      Whirly.start(
        spinner: 'star',
        remove_after_stop: true,
        append_newline: false,
        status: Paint[title, '#2794d8']
      )
      success = true
      begin
        block.call
      rescue
        success = false
        raise
      ensure
        Whirly.stop
        puts "#{success ? "\u2705" : "\u274c"} #{Paint[title, '#2794d8']}"
      end
    end

    def initialize_actuators
      ACTUATOR_TEMPLATES.each do |k,v|
        tmpl = ERB.new(v)
        File.write(File.join(path, 'env-meta', k), tmpl.result(render_binding(name, global)))
      end        
    end

    def render_binding(name, global = false)
      render_ctx = Module.new.class.tap do |eigen|
        eigen.define_method(:env_root) { global ? Config.global_depot_path : Config.user_depot_path }
        eigen.define_method(:env_cache) { global ? Config.global_cache_path : Config.user_cache_path }
        eigen.define_method(:env_name) { name }
        eigen.define_method(:env_global) { global }
      end
      render_ctx.instance_exec { binding }
    end
  end
end
