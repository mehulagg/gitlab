# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Segments
      class BulkDeleteService
        include CommonMethods

        def initialize(segments:, current_user:)
          @segments = segments
          @current_user = current_user
        end

        def execute
          authorize!

          result = nil

          ActiveRecord::Base.transaction do
            segments.each do |segment|
              response = delete_segment(segment)

              if response.error?
                result = ServiceResponse.error(message: response.message, payload: response_payload)
                raise ActiveRecord::Rollback
              end
            end

            result = ServiceResponse.success(payload: response_payload)
          end

          result
        end

        private

        attr_reader :segments, :current_user

        def response_payload
          { segments: segments }
        end

        def delete_segment(segment)
          DeleteService.new(current_user: current_user, segment: segment).execute
        end
      end
    end
  end
end
