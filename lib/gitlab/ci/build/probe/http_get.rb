# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      class Probe
        class HttpGet
          attr_reader :path, :port, :headers, :scheme

          def initialize(probe)
            @path = probe[:path]
            @port = probe[:port]
            @headers = probe[:headers]
            @scheme = probe[:scheme]
          end
        end
      end
    end
  end
end
