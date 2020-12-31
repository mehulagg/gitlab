# frozen_string_literal: true

module Gitlab
  module Metrics
    module Samplers
      # Records metrics that need to be probed for on a per-unit-of-time basis, rather than on a
      # per-job basis (the latter are tracked in server_metrics and client_metrics middleware.)
      #
      # NOTE: This sampler must not start before the sidekiq initializer has run, since it relies
      # on `Sidekiq.redis` to point to a fully initialized client.
      class SidekiqSampler < BaseSampler
        DEFAULT_SAMPLING_INTERVAL_SECONDS = 5

        def initialize(*)
          super
          @stats = Sidekiq::Stats.new
          @metrics = {
            sidekiq_queue_size: ::Gitlab::Metrics.gauge(:sidekiq_queue_size, 'The current length of the queue')
          }
        end

        def sample
          labels = {}

          sample_queue_sizes(labels)
        end

        private

        # Cost: 2 Redis roundtrips.
        # - 1 request to obtain all queue names
        # - N pipelined requests to read all lengths per queue
        #
        # See https://github.com/mperham/sidekiq/blob/6c94a9dd9f3ccbbd107c6ad2336c26a305020a25/lib/sidekiq/api.rb#L132-L147
        def sample_queue_sizes(labels)
          @stats.queues.each do |queue, length|
            @metrics[:sidekiq_queue_size].set(labels.merge(name: queue, queue: queue), length)
          end
        end
      end
    end
  end
end
