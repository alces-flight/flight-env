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
require_relative 'commands'
require_relative 'version'

require 'commander'
require_relative 'patches/highline-ruby_27_compat'

module Env
  module CLI
    PROGRAM_NAME = ENV.fetch('FLIGHT_PROGRAM_NAME','flenv')

    extend Commander::Delegates
    program :application, "Flight Environment"
    program :name, PROGRAM_NAME
    program :version, "v#{Env::VERSION}"
    program :description, 'Manage and access HPC application environments.'
    program :help_paging, false
    default_command :help
    silent_trace!

    error_handler do |runner, e|
      case e
      when InterruptedOperationError, TTY::Reader::InputInterrupt
        $stderr.puts "\n#{Paint['WARNING', :underline, :yellow]}: Cancelled by user"
        exit(130)
      else
        Commander::Runner::DEFAULT_ERROR_HANDLER.call(runner, e)
      end
    end

    if ENV['TERM'] !~ /^xterm/ && ENV['TERM'] !~ /rxvt/
      Paint.mode = 0
    end

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
      c.option '-g', '--global', 'Consider global application environments only.'
    end

    command :deactivate do |c|
      cli_syntax(c)
      c.description = 'Deactivate the current application environment'
      c.action Commands, :deactivate
    end

    command :switch do |c|
      cli_syntax(c, 'TYPE[@NAME]')
      c.description = 'Switch to a different application environment'
      c.option '-g', '--global', 'Consider global application environments only.'
      c.action Commands, :switch
    end

    command :avail do |c|
      cli_syntax(c)
      c.description = "Show available application environment types"
      c.action Commands, :list_types
    end

    command :list do |c|
      cli_syntax(c)
      c.description = "List configured application environments"
      c.option '-g', '--global', 'Consider global application environments only.'
      c.action Commands, :list_envs
    end

    command :create do |c|
      cli_syntax(c, 'TYPE[@NAME]')
      c.description = "Create a new application environment"
      c.option '-g', '--global', 'Create a global application environment.'
      c.action Commands, :create
    end

    command :purge do |c|
      cli_syntax(c, 'TYPE[@NAME]')
      c.description = "Purge an existing application environment"
      c.option '-g', '--global', 'Consider global application environments only.'
      c.option '--yes', 'Purge without prompting (DANGEROUS)'
      c.action Commands, :purge
    end

    # command :'describe-env' do |c|
    #   cli_syntax(c, 'NAME')
    #   c.description = "Show information about an application environment"
    #   c.action Commands, :describe_env
    # end

    command :info do |c|
      cli_syntax(c, 'NAME')
      c.description = "Show information about an application environment type"
      c.action Commands, :describe_type
    end

    command :'show-active' do |c|
      cli_syntax(c)
      c.description = "Show currently active application environment"
      c.option '--empty-if-unset', 'Don\'t display output if no environment is active.'
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
      c.option '--remove', "Deprecated option for removing the default application environment."
      c.option '--system', 'Set the system default application environment.'
      c.option '--use_system', 'Use the system default application environment'
      c.action Commands, :set_default
    end

    command :'remove-default' do |c|
      cli_syntax(c)
      c.description = "Remove the default application environment"
      c.option '--system', 'Set the system default application environment.'
      c.action Commands, :remove_default
    end
  end
end
