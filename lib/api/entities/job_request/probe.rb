# frozen_string_literal: true

module API
  module Entities
    module JobRequest
      class Probe < Grape::Entity
        with_options(expose_nil: false) do
          expose :tcp
          expose :http_get
          expose :exec
          expose :retries
          expose :initial_delay
          expose :period
          expose :timeout
        end
      end
    end
  end
end
