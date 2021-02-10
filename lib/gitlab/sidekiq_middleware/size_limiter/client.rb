# frozen_string_literal: true

module Gitlab
  module SidekiqMiddleware
    module SizeLimiter
      class Client
        def call(worker_class, job, queue, _redis_pool)
          Validator.validate!(worker_class, job)

          yield
        end
      end
    end
  end
end
