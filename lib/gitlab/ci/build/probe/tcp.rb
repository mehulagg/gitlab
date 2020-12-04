# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      class Probe
        class Tcp
          attr_reader :port

          def initialize(probe)
            @port = probe[:port]
          end
        end
      end
    end
  end
end
