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
require 'env/errors'

module Env
  class Environment
    DEFAULT = 'default'

    class << self
      def active
        ENV['flight_ENV_active']
      end

      def each(&block)
        all.values.each(&block)
      end

      def [](k)
        k += "@#{DEFAULT}" unless k.include?('@')
        all[k.to_sym].tap do |e|
          if e.nil?
            raise NoSuchEnvironmentError, "unknown environment: #{k}"
          end
        end
      end

      def default
        Config.user_data.fetch(:default_environment)
      end

      def remove_default
        Config.user_data.delete(:default_environment)
        Config.save_user_data
      end

      def set_default(type, name = DEFAULT)
        name ||= DEFAULT
        self[[type, name].join('@')].tap do |env|
          Config.user_data.set(:default_environment, value: env.to_s)
          Config.save_user_data
        end
      end

      def all
        @envs ||=
          begin
            {}.tap do |h|
                h.merge!(envs_for(Config.user_depot_path, false))
                h.merge!(envs_for(Config.global_depot_path, true))
            end
          end
      end

      def envs_for(path, global)
        {}.tap do |h|
          Dir[File.join(path,'*')].sort.each do |d|
            dir_name = File.basename(d)
            next unless File.directory?(d) && dir_name.match?(/.*\+.*/)
            type, name = dir_name.split('+')
            begin
              e = Environment.new(Type[type], name, global)
              h[e.to_s.to_sym] = e
            rescue
              nil
            end
          end
        end
      end

      def create(type, name: DEFAULT, global: false)
        # if unknown type, error
        if type.nil?
          raise UnknownEnvironmentTypeError, "unknown environment type"
        end
        env_name = [type.name,name].join('@')
        # if exists, error
        if (self[env_name] rescue nil)
          raise EnvironmentExistsError, "environment already exists: #{env_name}"
        end

        env = type.create(name: name, global: global)
      end

      def purge(type, name: DEFAULT)
        # if unknown type, error
        if type.nil?
          raise UnknownEnvironmentTypeError, "unknown environment type"
        end
        env_name = [type.name,name].join('@')
        env = self[env_name]
        type.purge(name: name, global: env.global?)
      end
    end

    attr_accessor :name, :type, :global

    def initialize(type, name, global = false)
      @type = type
      @name = name
      @global = global
    end

    def to_s
      [@type.name, @name].join("@")
    end

    def global?
      self.global
    end

    def activator
      type.activator(name, global)
    end
  end
end
