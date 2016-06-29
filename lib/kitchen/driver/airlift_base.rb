#
# Copyright (C) 2016, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "shellwords"

require "kitchen/driver/base"
require "thor/util"

require "airlift"


module Kitchen
  module Driver
    # Base class for drivers that need to run commands on some kind of
    # host, which could be either local or remote.
    class AirliftBase < Base
      default_config :transport, {}

      # Shut down any active connection.
      #
      # @return [void]
      def cleanup!
        if @airlift
          @airlift.close
          @airlift = nil
        end
      end

      private

      # Create the Airlift connection instance. This is cached.
      #
      # @return [Airlift::Connection::Base]
      def airlift
        @airlift ||= begin
          transport_config = config[:transport].dup
          # Pull out the plugin name, if a hostname is set default to
          # the same as the instance transport otherwise default to local.
          plugin_name = transport_config[:name] || if transport_config[:hostname]
            Thor::Util.snake_case(instance.transport.class.name.split(/::/).last)
          else
            'local'
          end
          Airlift.connect(name: plugin_name, logger: logger, **transport_config)
        end
      end

    end
  end
end
