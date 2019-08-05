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
require 'env/command'
require 'env/environment'
require 'env/errors'
require 'env/type'

module Env
  module Commands
    class Activate < Command
      def run
        active_env = Environment.active
        unless active_env.nil?
          raise ActiveEnvironmentError, "existing active environment detected: #{active_env}"
        end
        if ENV['flight_ENV_eval'].nil?
          if options.interactive
            puts "Activating: #{@args.first}"
            shell = '/bin/bash'
            Bundler.with_clean_env do
              exec(
                {
                  'flight_ENV_shell' => @args.first,
                  'flight_ROOT' => ENV['flight_ROOT']
                },
                [shell,'flight-env'],
                '--rcfile',
                File.join(Config.root,'etc','bashrc')
              )
            end
          else
            raise EvaluatorError, "direct activation not possible; try --interactive, or: flenv activate #{args[0]}"
          end
        end
        type, name = args[0].split('@')
        puts Type[type].activator(*(name))
      end
    end
  end
end
