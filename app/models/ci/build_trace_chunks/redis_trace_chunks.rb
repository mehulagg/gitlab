# frozen_string_literal: true

module Ci
  module BuildTraceChunks
    class RedisTraceChunks < RedisBase
      private

      def with_redis(&block)
        # TODO use Gitlab::Redis::TraceChunks
        Gitlab::Redis::SharedState.with { |redis| block.call(redis) }
      end
    end
  end
end
