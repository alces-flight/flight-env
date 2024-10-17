# coding: utf-8
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
require_relative '../command'
require_relative '../table'
require_relative '../plugin'

module Env
  module Commands
    class ListPlugins < Command
      def run
        if Plugin.all.empty?
          puts "No environment plugins found."
        else
          cmd = self
          Table.emit do |t|
            headers 'Name', 'Summary'
            Env::Plugin.each do |t|
              row Paint[t.name, :cyan], cmd.word_wrap("#{Paint[t.summary, :green]}\n > #{Paint[t.url, :blue, :bright, :underline]}\n ", line_width: TTY::Screen.width - 30)
            end
          end
        end
      end
    end
  end
end
