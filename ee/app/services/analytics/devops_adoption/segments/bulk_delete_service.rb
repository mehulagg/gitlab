# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Segments
      class BulkDeleteService
        def initialize(segments:, current_user:)
          @segments = segments
          @current_user = current_user
        end

        def execute
          deletion_services.map(&:authorize!)

          result = nil

          ActiveRecord::Base.transaction do
            deletion_services.each do |service|
              response = service.execute

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

        def deletion_services
          @deletion_services ||= segments.map do |segment|
            DeleteService.new(current_user: current_user, segment: segment)
          end
        end
      end
    end
  end
end
