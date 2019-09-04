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
require 'env/command'
require 'env/environment'
require 'env/type'
require 'tty/prompt'

module Env
  module Commands
    class Purge < Command
      def run
        Environment.global_only = true if @options.global
        target_env = Environment[args[0]]
        if target_env == Environment.active
          raise ActiveEnvironmentError, "environment currently active: #{target_env}"
        end
        prompt = TTY::Prompt.new
        do_purge = @options.yes || prompt.yes?(
          "Purge #{target_env.global? ? 'global ' : ''}environment #{pretty_name(target_env)}?"
        ) do |q|
          q.default false
        end
        if do_purge
          target_env.purge
        else
          puts "#{target_env.global? ? 'Global e' : 'E'}Environment #{pretty_name(target_env)} not purged."
        end
      end
    end
  end
end
