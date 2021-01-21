# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Segments
      class CreateService
        include Gitlab::Allowable

        def initialize(segment: Analytics::DevopsAdoption::Segment.new, params: {}, current_user:)
          @segment = segment
          @params = params
          @current_user = current_user
        end

        def execute
          unless can?(current_user, :manage_devops_adoption_segments, :global)
            return ServiceResponse.error(message: 'Forbidden', payload: response_payload)
          end

          segment.assign_attributes(attributes)

          if segment.save
            Analytics::DevopsAdoption::CreateSnapshotWorker.perform_async(segment.id, nil)

            ServiceResponse.success(payload: response_payload)
          else
            ServiceResponse.error(message: 'Validation error', payload: response_payload)
          end
        end

        private

        attr_reader :segment, :params, :current_user

        def response_payload
          { segment: segment }
        end

        def attributes
          params.slice(:namespace, :namespace_id)
        end
      end
    end
  end
end
