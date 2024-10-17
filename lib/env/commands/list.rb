# coding: utf-8
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
require 'env/command'
require 'env/environment'
require 'env/table'

module Env
  module Commands
    class List < Command
      def run
        target_env = if args[0].nil?
                       Environment.active.tap do |active_env|
                         if active_env.nil?
                           raise ActiveEnvironmentError, "no active environment"
                         end
                       end
                     else
                       Environment[args[0]]
                     end
        if target_env
          plugins = target_env.plugins
          if plugins.empty?
            puts "No plugins have been added to this environment."
          else
            cmd = self
            Table.emit do |t|
              headers 'Name', 'Version'
              plugins.each do |t|
                row Paint[t.name, :cyan], Paint[t.version, :magenta]
              end
            end
          end
        end
      end
    end
  end
end
