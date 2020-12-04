# frozen_string_literal: true

module API
  module Entities
    module JobRequest
      class Image < Grape::Entity
        expose :name, :entrypoint
        expose :ports, using: Entities::JobRequest::Port
        expose :probes, using: Entities::JobRequest::Probe, expose_nil: false
      end
    end
  end
end
