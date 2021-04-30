# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Segments
      class DeleteService
        include CommonMethods

        def initialize(segment:, current_user:)
          @segment = segment
          @current_user = current_user
        end

        def execute
          authorize!

          begin
            segment.destroy!

            ServiceResponse.success(payload: response_payload)
          rescue ActiveRecord::RecordNotDestroyed
            ServiceResponse.error(message: 'DevOps Adoption Segment deletion error', payload: response_payload)
          end
        end

        private

        attr_reader :segment

        delegate :namespace, :display_namespace, to: :segment

        def response_payload
          { segment: segment }
        end
      end
    end
  end
end
