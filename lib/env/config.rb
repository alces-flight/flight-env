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
require 'xdg'
require 'tty-config'
require 'fileutils'

module Env
  module Config
    class << self
      ENV_DIR_SUFFIX = File.join('flight','env')

      def data
        @data ||= TTY::Config.new.tap do |cfg|
          cfg.append_path(File.join(root, 'etc'))
          begin
            cfg.read
          rescue TTY::Config::ReadError
            nil
          end
        end
      end

      def user_data
        @user_data ||= TTY::Config.new.tap do |cfg|
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

      def save_user_data
        FileUtils.mkdir_p(
          File.join(
            xdg_config.home,
            ENV_DIR_SUFFIX
          )
        )
        user_data.write(force: true)
      end

      def user_depot_path
        @user_depot_path ||= File.join(xdg_data.home, ENV_DIR_SUFFIX)
      end

      def user_build_cache_path
        @user_build_cache_path ||= File.join(user_cache_path, 'build')
      end

      def user_cache_path
        @user_cache_path ||= File.join(xdg_cache.home, ENV_DIR_SUFFIX)
      end

      def global_depot_path
        @global_depot_path ||= data.fetch(
          :global_depot_path,
          default: '/opt/flight/var/lib/env'
        )
      end

      def global_build_cache_path
        @global_build_cache_path ||= data.fetch(
          :global_build_cache_path,
          default: '/opt/flight/var/cache/env/build'
        )
      end

      def global_cache_path
        @global_cache_path ||= data.fetch(
          :global_cache_path,
          default: '/opt/flight/var/cache/env'
        )
      end

      def path
        config_path_provider.path ||
          config_path_provider.paths.first
      end

      def root
        @root ||= File.expand_path(File.join(__dir__, '..', '..'))
      end

      def type_paths
        @type_paths ||=
          data.fetch(
            :type_paths,
            default: [
              'etc/types'
            ]
          ).map {|p| File.expand_path(p, Config.root)}
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
