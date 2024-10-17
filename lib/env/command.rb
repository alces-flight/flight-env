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
require 'ostruct'

module Env
  class Command
    attr_accessor :args, :options

    def initialize(args, options, command_name = nil)
      @args = args.freeze
      @options = OpenStruct.new(options.__hash__)
    end

    # this wrapper is here to later enable error handling &/ logging
    def run!
      run
    end

    def run
      raise NotImplementedError
    end

    def pretty_name(env)
      env_type = (env.is_a? Environment) ? env.type.name : env.split('@')[0]
      env_name = (env.is_a? Environment) ? env.name      : env.split('@')[1]
      Paint[env_type, :cyan] +
        '@' + Paint[env_name, :magenta]
    end

    def word_wrap(text, line_width: 80, break_sequence: "\n")
      text.split("\n").collect! do |line|
        line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1#{break_sequence}").strip : line
      end * break_sequence
    end
  end
end
