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

module Env
  module Commands
    class Switch < Command
      def run
        Environment.global_only = true if @options.global
        active_env = Environment.active
        target_env = Environment[args[0]]
        if active_env.nil?
          assert_evaluatable
          puts target_env.activator
          return
        elsif active_env == target_env
          return if ENV.fetch('flight_MODE','interactive') == 'batch'
          raise ActiveEnvironmentError, "environment already active: #{active_env}"
        end
        assert_evaluatable
        puts active_env.deactivator
        puts target_env.activator
      end

      private
      def assert_evaluatable
        if ENV['flight_ENV_eval'].nil?
          shell = Shell.type
          if shell == Shell::UNK
            raise EvaluatorError, "unrecognized shell: #{Shell.type_name}"
          end
          cmd = shell.eval_cmd_for("switch #{args[0]}")
          raise EvaluatorError, "directly executed switch not possible; try: '#{cmd}'"
        end
      end
    end
  end
end
