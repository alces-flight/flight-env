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
require_relative 'config'

require 'sys/proctable'

module Env
  class Shell
    class << self
      def [](name)
        shells[name]
      end

      def []=(name, shell)
        shells[name] = shell
      end

      def shells
        @shells ||= {}
      end

      def type_name
        if name = ENV['flight_ENV_shell']
          name
        else
          Sys::ProcTable
                .ps(pid: Process.ppid)
                .name
        end
      end

      def type
        Shell[type_name] || UNK
      end
    end

    attr_reader :name, :exit_cmd, :eval_cmd, :args, :env, :path

    def initialize(name, exit_cmd = nil, eval_cmd = nil, args = [], env = {}, path = nil)
      @name = name
      @exit_cmd = exit_cmd
      @eval_cmd = eval_cmd
      @args = args
      @env = env
      @path = path || "/bin/#{name}"
      Shell[name] = self
    end

    def eval_cmd_for(cmd)
      sprintf(
        ENV.fetch(
          'flight_ENV_eval_cmd',
          eval_cmd
        ),
        cmd
      )
    end

    BASH = Shell.new(
      'bash',
      'exit',
      %(eval "$(flight_ENV_eval=true #{$0} %s)"),
      [
        '--rcfile',
        File.join(Config.root,'etc','bash','bashrc')
      ]
    )
    TCSH = Shell.new(
      'tcsh',
      'logout',
      %(eval `(setenv flight_ENV_eval true; #{$0} %s)`),
      [
        '-l'
      ],
      {
        'flight_ENV_root' => Config.root,
        'HOME' => File.join(Config.root,'etc','tcsh')
      }
    )
    UNK = Shell.new('unknown')
  end
end
