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
require 'xdg'
require 'tty-config'
require 'fileutils'

module Env
  module Config
    class << self
      ENV_DIR_SUFFIX = File.join('flight','env')

      def save
        FileUtils.mkdir_p(
          File.join(
            xdg_config.home,
            ENV_DIR_SUFFIX
          )
        )
        data.write(force: true)
      end

      def data
        @data ||= TTY::Config.new.tap do |cfg|
          xdg_config.all.map do |p|
            File.join(p, ENV_DIR_SUFFIX)
          end.each(&cfg.method(:append_path))
          begin
            cfg.read
          rescue TTY::Config::ReadError
            nil
          end
        end
      end

      def user_depot_path
        @user_depot_path ||= File.join(xdg_data.home, ENV_DIR_SUFFIX)
      end

      def user_build_cache_path
        @user_build_cache_path ||= File.join(xdg_cache.home, ENV_DIR_SUFFIX, 'build')
      end

      def system_depot_path
        @system_depot_path ||= '/opt/flight/var/lib/env'
      end

      def system_build_cache_path
        @system_build_cache_path ||= '/opt/flight/var/cache/env/build'
      end

      def path
        config_path_provider.path ||
          config_path_provider.paths.first
      end

      def root
        @root ||= File.expand_path(File.join(__dir__, '..', '..'))
      end

      def types_path
        @types_path ||= File.join(root, 'etc', 'envs')
      end

      def environments
        @environments ||=
          EnvironmentConfig.new(data.fetch(:environments, default: []))
      end

      class EnvironmentConfig
        def initialize(environments)
          @environments = environments
        end

        def exists?(name)
          @environments.include?(name)
        end

        def <<(name)
          @environments << name
          Config.data.set(:environments, value: @environments)
          Config.save
        end

        def delete(name)
          @environments.reject! { |e| e == name }
          Config.data.set(:environments, value: @environments)
          Config.save
        end
      end

      private
      def xdg_config
        @xdg_config ||= XDG::Config.new
      end

      def xdg_data
        @xdg_data ||= XDG::Data.new
      end

      def xdg_cache
        @xdg_cache ||= XDG::Cache.new
      end
    end
  end
end
