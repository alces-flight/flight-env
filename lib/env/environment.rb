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
        all[k.to_sym].tap do |e|
          if e.nil?
            raise NoSuchEnvironmentError, "unknown environment: #{k}"
          end
        end
      end

      def default
        Config.data.fetch(:default_environment).gsub('+','@')
      end

      def remove_default
        Config.data.delete(:default_environment)
        Config.save
      end

      def set_default(type, name = DEFAULT)
        name ||= DEFAULT
        e = [type, name].join('+')
        if all.keys.include?(e.to_sym)
          Config.data.set(:default_environment, value: e)
        else
          raise NoSuchEnvironmentError, "unknown environment: #{[type, name].join('@')}"
        end
        Config.save
        self[e]
      end

      def all
        @envs ||=
          begin
            {}.tap do |h|
              Dir[File.join(Config.user_depot_path,'*')].sort.each do |d|
                name = File.basename(d)
                next unless File.directory?(d) && name.match?(/.*\+.*/)
                h[name.to_sym] = Environment.new(name)
              end
            end
          end
      end

      def create(type, name = DEFAULT)
        # if unknown type, error
        if type.nil?
          raise UnknownEnvironmentTypeError, "unknown environment type"
        end
        env_name = [type.name,name].join('@')
        # if exists, error
        if Config.environments.exists?(env_name)
          raise EnvironmentExistsError, "environment already exists"
        end

        type.create(name)
        Config.environments << env_name
      end

      def purge(type, name = DEFAULT)
        # if unknown type, error
        if type.nil?
          raise UnknownEnvironmentTypeError, "unknown environment type"
        end
        env_name = [type.name,name].join('@')
        # if not exists, error
        if ! Config.environments.exists?(env_name)
          raise NoSuchEnvironmentError, "environment not found"
        end

        type.purge(name)
        Config.environments.delete(env_name)
      end
    end

    attr_accessor :name, :type

    def initialize(name)
      @type, @name = name.split('+')
    end

    def to_s
      [@type, @name].join("@")
    end
  end
end
