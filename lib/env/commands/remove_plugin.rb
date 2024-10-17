# =============================================================================
# Copyright (C) 2024-present Alces Flight Ltd.
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
require_relative '../command'
require_relative '../plugin'

module Env
  module Commands
    class RemovePlugin < Command
      def run
        target_env = Environment[args[1]]
        active_env = Environment.active
        if active_env == target_env
          raise ActiveEnvironmentError, "unable to remove plugin from active environment: #{active_env}"
        end
        plugin = target_env.plugins.find {|p| p.name == args[0]}
        if plugin.nil?
          raise UnknownEnvironmentPluginError, "plugin '#{args[0]}' is not installed in environemnt: #{args[1]}"
        else
          plugin.remove(target_env)
        end
      end
    end
  end
end
