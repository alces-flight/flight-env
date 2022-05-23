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
module Env
  module Commands
    class SetDefault < Command
      def run
        if @options.use_system
          Environment.remove_default(false)
          Environment.system_default_opt_out(false)
          puts "Default login environment has been set to the system-wide default."
          if d = Environment.default
            puts "Currently set to: #{d}"
          else
            puts "Currently, no system default is set."
          end
        else
          if @args.empty?
            raise OptionParser::MissingArgument, "must specify environment when setting default"
          end
          system = @options.system
          e = Environment.set_default(args[0], system)
          puts "Default #{ system ? "system-wide " : "" }environment set to: #{e}"
        end
      end
    end
  end
end
