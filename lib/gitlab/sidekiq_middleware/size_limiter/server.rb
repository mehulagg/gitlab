# frozen_string_literal: true

module Gitlab
  module SidekiqMiddleware
    module SizeLimiter
      class Server
        def call(worker, job, queue)
          # Note: offloaded should be handled from the server side regardless of the track mode
          # Note 2: The logger is independent from the middleware stack. Hence, offloaded jobs will have `args = null`. Is that acceptable?
          # Handle action mailer
          compressed = job.delete('offloaded')
          if compressed
            # What if the uploader fails to load the job?
            compressed_args = job.delete('compressed_args')
            job['args'] = decompress(compressed_args)
          end

          yield
        end
      end

      private

      def decompress(data)
        Sidekiq.load_json(Zlib::Deflate.inflate(Base64.decode64(data)))
      end
    end
  end
end
