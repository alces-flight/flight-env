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
require 'env/command'
require 'env/environment'
require 'env/errors'
require 'env/type'
require_relative '../shell'

module Env
  module Commands
    class Activate < Command
      def run
        Environment.global_only = true if @options.global
        active_env = Environment.active
        target_env = Environment[args[0]]
        if active_env == target_env
          return if ENV.fetch('flight_MODE','interactive') == 'batch'
          raise ActiveEnvironmentError, "environment already active: #{active_env}"
        elsif !active_env.nil?
          raise ActiveEnvironmentError, "existing active environment detected: #{active_env}"
        end
        if ENV['flight_ENV_eval'].nil?
          shell = Shell.type
          if shell == Shell::UNK
            raise EvaluatorError, "unrecognized shell: #{Shell.type_name}"
          elsif options.subshell
            puts "Activating environment #{pretty_name(target_env)}"
            with_clean_env do
              exec(
                shell.env.merge('flight_ENV_subshell_env' => @args.first),
                [shell.path,'flight-env'],
                *(shell.args)
              )
            end
          else
            cmd = shell.eval_cmd_for("activate #{args[0]}")
            raise EvaluatorError, "directly executed activation not possible; try --subshell, or: '#{cmd}'"
          end
        end
        puts target_env.activator
      end

      private
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
end
