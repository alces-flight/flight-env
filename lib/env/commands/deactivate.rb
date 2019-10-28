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
    class Deactivate < Command
      def run
        active_env = Environment.active
        if active_env.nil?
          raise ActiveEnvironmentError, 'no active environment'
        end
        shell = Shell.type
        if shell == Shell::UNK
          raise EvaluatorError, "unrecognized shell: #{Shell.type_name}"
        end
        if ENV['flight_ENV_eval'].nil?
          cmd = shell.eval_cmd_for('deactivate')
          raise EvaluatorError, "directly executed deactivation not possible; try: '#{cmd}'"
        elsif ENV['flight_ENV_subshell_env']
          puts shell.exit_cmd
        else
          puts active_env.deactivator
        end
      end
    end
  end
end
