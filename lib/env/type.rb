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
# https://github.com/alces-flight/flight-env
# ==============================================================================
require 'env/config'
require 'env/errors'
require 'env/shell'

require 'erb'
require 'fileutils'
require 'yaml'

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
      puts "Creating environment: #{self.name}@#{name}"
      if File.exists?(install_script(global))
        Bundler.with_clean_env do
          IO.popen(
            {
              'flight_ENV_ROOT' => depot_path(global),
              'flight_ENV_CACHE' => build_cache_path(global),
            },
            [
              '/bin/bash',
              install_script(global),
              name
            ]
          ) do |io|
            puts io.readlines
          end
        end
      else
        raise IncompleteTypeError, "no #{global ? 'global ' : ''}creation script provided for type: #{self.name}"
      end
      Environment.new(self, name, global)
    end

    def purge(name: DEFAULT, global: false)
      puts "Purging environment: #{self.name}@#{name}"
      if File.exists?(purge_script(global))
        Bundler.with_clean_env do
          IO.popen(
            {
              'flight_ENV_ROOT' => depot_path(global),
              'flight_ENV_CACHE' => build_cache_path(global),
            },
            [
              '/bin/bash',
              purge_script(global),
              name
            ]
          ) do |io|
            puts io.readlines
          end
        end
      else
        raise IncompleteTypeError, "no #{global ? 'global ' : ''}purge script provided for type: #{self.name}"
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
  end
end
