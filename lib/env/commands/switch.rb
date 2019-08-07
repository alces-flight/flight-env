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
require 'env/errors'
require 'env/type'

module Env
  module Commands
    class Switch < Command
      def run
        active_env = Environment.active
        if active_env.nil?
          assert_evaluatable
          activate
          return
        elsif active_env == args[0] || active_env == [args[0],'default'].join('@')
          raise ActiveEnvironmentError, "environment already active: #{active_env}"
        end
        assert_evaluatable
        type, name = active_env.split('@')
        puts Type[type].deactivator(*(name))
        activate
      end

      private
      def assert_evaluatable
        if ENV['flight_ENV_eval'].nil?
          raise EvaluatorError, "direct switching not possible; try: flenv switch #{args[0]}"
        end
      end

      def activate
        puts Environment[args[0]].activator
      end
    end
  end
end
