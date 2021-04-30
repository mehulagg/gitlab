# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Segments
      class CreateService
        include CommonMethods

        def initialize(segment: Analytics::DevopsAdoption::Segment.new, params: {}, current_user:)
          @segment = segment
          @params = params
          @current_user = current_user
        end

        def execute
          authorize!

          segment.assign_attributes(namespace: namespace, display_namespace: display_namespace)

          if segment.save
            Analytics::DevopsAdoption::CreateSnapshotWorker.perform_async(segment.id)

            ServiceResponse.success(payload: response_payload)
          else
            ServiceResponse.error(message: 'Validation error', payload: response_payload)
          end
        end

        private

        attr_reader :segment

        def response_payload
          { segment: segment }
        end
      end
    end
  end
end
