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
require_relative '../plugin'

require 'ronn'

module Env
  module Commands
    class DescribePlugin < Command
      def run
        arg_plugin = args[0]
        plugin = Plugin[arg_plugin]
        options = {
          date: File.stat(plugin.info_file).ctime,
          manual: 'OpenFlight Software Environments',
          organization: plugin.author || 'Alces Flight Ltd',
        }
        doc = Ronn::Document.new(plugin.info_file, options) do |f|
          File.read(f).tap do |s|
            s.gsub!('%PROGRAM_NAME%', Env::CLI::PROGRAM_NAME)
          end
        end
        pager = ENV['MANPAGER'] || ENV['PAGER'] || 'less -FRX'
        groff = 'groff -Wall -mtty-char -mandoc -Tascii'
        rd, wr = IO.pipe
        if pid = fork
          rd.close
        else
          wr.close
          STDIN.reopen rd
          exec "#{groff} | #{pager}"
        end
        wr.puts(doc.to_roff)
        wr.close
        Process.wait(pid)
      end
    end
  end
end
