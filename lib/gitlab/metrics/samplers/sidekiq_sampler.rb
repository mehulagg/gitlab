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
            sidekiq_queue_size:    ::Gitlab::Metrics.gauge(:sidekiq_queue_size, 'The current length of the queue'),
            sidekiq_queue_latency: ::Gitlab::Metrics.gauge(:sidekiq_queue_latency_seconds, 'Time elapsed since the oldest job was enqueued')
          }
        end

        def sample
          labels = {}

          sample_queue_stats(labels)
        end

        private

        # Cost: 2 Redis roundtrips.
        # - 1 request to obtain all queue names
        # - N pipelined requests to read all jobs per queue
        def sample_queue_stats(labels)
          queue_stats = Sidekiq.redis do |conn|
            queues = conn.sscan_each("queues").to_a

            jobs = conn.pipelined do
              queues.each do |queue|
                conn.lrange("queue:#{queue}", -1, -1)
              end
            end

            queues.zip(jobs).to_h do |queue, queue_jobs|
              [queue, {
                length: queue_jobs.size,
                latency: queue_latency_from_jobs(queue_jobs)
              }]
            end
          end

          queue_stats.each do |queue, stats|
            @metrics[:sidekiq_queue_size].set(labels.merge(name: queue, queue: queue), stats[:length])
            @metrics[:sidekiq_queue_latency].set(labels.merge(name: queue, queue: queue), stats[:latency])
          end
        end

        # Cf. https://github.com/mperham/sidekiq/blob/6c94a9dd9f3ccbbd107c6ad2336c26a305020a25/lib/sidekiq/api.rb#L227-L241
        def queue_latency_from_jobs(job_list)
          entry = job_list.first
          return 0 unless entry

          job = Sidekiq.load_json(entry)
          now = Time.now.to_f
          thence = job["enqueued_at"] || now
          now - thence
        end
      end
    end
  end
end
