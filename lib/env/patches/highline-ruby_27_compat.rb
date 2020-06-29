# =============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Desktop.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Desktop is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Desktop. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Desktop, please visit:
# https://github.com/alces-flight/flight-desktop
# ==============================================================================
# Ensure HighLine doesn't output deprecation warnings for Ruby 2.7
class HighLine
  def say(statement)
    statement = format_statement(statement)
    return unless statement.length > 0

    out = (indentation+statement).encode(Encoding.default_external, :undef => :replace)

    # Don't add a newline if statement ends with whitespace, OR
    # if statement ends with whitespace before a color escape code.
    if /[ \t](\e\[\d+(;\d+)*m)?\Z/ =~ statement
      @output.print(out)
      @output.flush
    else
      @output.puts(out)
    end
  end
end
