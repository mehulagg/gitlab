# frozen_string_literal: true

module Gitlab
  module Redis
    class TraceChunks < ::Gitlab::Redis::Wrapper
      class << self
        def default_url
          'redis://localhost:6383'
        end
      end
    end
  end
end
