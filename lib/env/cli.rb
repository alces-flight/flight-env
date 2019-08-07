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
# https://github.com/alces-flight/flight-env
# ==============================================================================
require 'env/commands'
require 'env/version'

require 'commander'

module Env
  module CLI
    PROGRAM_NAME = ENV.fetch('FLIGHT_PROGRAM_NAME','env')

    extend Commander::Delegates
    program :application, "Flight Environment"
    program :name, PROGRAM_NAME
    program :version, "Release 2019.1 (v#{Env::VERSION})"
    program :description, 'Manage and access HPC application environments.'
    program :help_paging, false
    default_command :help
    silent_trace!

    class << self
      def cli_syntax(command, args_str = nil)
        command.syntax = [
          PROGRAM_NAME,
          command.name,
          args_str
        ].compact.join(' ')
      end
    end

    command :activate do |c|
      cli_syntax(c, 'TYPE[@NAME]')
      c.description = 'Activate an application environment'
      c.action Commands, :activate
      c.option '-s', '--subshell', 'Open an interactive subshell with TYPE environment activated.'
    end

    command :deactivate do |c|
      cli_syntax(c)
      c.description = 'Deactivate the current application environment'
      c.action Commands, :deactivate
    end

    command :switch do |c|
      cli_syntax(c, 'TYPE[@NAME]')
      c.description = 'Switch to a different application environment'
      c.action Commands, :switch
    end

    command :'list-envs' do |c|
      cli_syntax(c)
      c.description = "List available application environments"
      c.action Commands, :list_envs
    end

    command :'list-types' do |c|
      cli_syntax(c)
      c.description = "List available application environment types"
      c.action Commands, :list_types
    end

    command :create do |c|
      cli_syntax(c, 'TYPE[@NAME]')
      c.description = "Create a new application environment"
      c.option '--global', 'Create a shared application environment.'
      c.action Commands, :create
    end

    command :purge do |c|
      cli_syntax(c, 'TYPE[@NAME]')
      c.description = "Purge an existing application environment"
      c.action Commands, :purge
    end

    command :'describe-env' do |c|
      cli_syntax(c, 'NAME')
      c.description = "Show information about an application environment"
      c.action Commands, :describe_env
    end

    command :'describe-type' do |c|
      cli_syntax(c, 'NAME')
      c.description = "Show information about an application environment type"
      c.action Commands, :describe_type
    end

    command :'show-active' do |c|
      cli_syntax(c)
      c.description = "Show currently active application environment"
      c.action Commands, :show_active
    end

    command :'show-default' do |c|
      cli_syntax(c)
      c.description = "Show the default application environment"
      c.option '--empty-if-unset', 'Don\'t display output if a default is not set.'
      c.action Commands, :show_default
    end

    command :'set-default' do |c|
      cli_syntax(c, '[NAME]')
      c.description = "Set the default application environment"
      c.option '--remove', 'Remove the default application environment if it is set.'
      c.action Commands, :set_default
    end
  end
end
