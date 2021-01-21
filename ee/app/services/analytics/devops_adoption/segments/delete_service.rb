# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Segments
      class DeleteService
        include Gitlab::Allowable

        def initialize(segment:, current_user:)
          @segment = segment
          @current_user = current_user
        end

        def execute
          unless can?(current_user, :manage_devops_adoption_segments, :global)
            return ServiceResponse.error(message: 'Forbidden', payload: response_payload)
          end

          begin
            segment.destroy!
            ServiceResponse.success(payload: response_payload)
          rescue ActiveRecord::RecordNotDestroyed
            ServiceResponse.error(message: 'Devops Adoption Segment deletion error', payload: response_payload)
          end
        end

        private

        attr_reader :segment, :current_user

        def response_payload
          { segment: @segment }
        end
      end
    end
  end
end
