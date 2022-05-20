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
require 'env/commands/activate'
require 'env/commands/deactivate'
require 'env/commands/create'
require 'env/commands/describe_type'
require 'env/commands/list_envs'
require 'env/commands/list_types'
require 'env/commands/purge'
require 'env/commands/remove_default'
require 'env/commands/set_default'
require 'env/commands/show_active'
require 'env/commands/show_default'
require 'env/commands/switch'

module Env
  module Commands
    class << self
      def method_missing(s, *a, &b)
        if clazz = to_class(s)
          clazz.new(*a).run!
        else
          raise 'command not defined'
        end
      end

      def respond_to_missing?(s)
        !!to_class(s)
      end

      private
      def to_class(s)
        s.to_s.split('-').reduce(self) do |clazz, p|
          p.gsub!(/_(.)/) {|a| a[1].upcase}
          clazz.const_get(p[0].upcase + p[1..-1])
        end
      rescue NameError
        nil
      end
    end
  end
end
