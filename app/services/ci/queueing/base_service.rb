# frozen_string_literal: true

module Ci
  module Queueing
    class BaseService
      attr_reader :runner, :metrics

      def initialize(runner)
        @runner = runner
        @metrics = ::Gitlab::Ci::Queue::Metrics.new(runner)
      end

      def enqueue(build)
        raise NotImplementedError
      end

      def dequeue_each(params, &blk)
        raise NotImplementedError
      end

      def queue_valid?
        raise NotImplementedError
      end

      def self.matching?(runner)
        raise NotImplementedError
      end
    end
  end
end