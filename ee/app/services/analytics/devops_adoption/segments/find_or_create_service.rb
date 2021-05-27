# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Segments
      class FindOrCreateService
        include CommonMethods

        def initialize(params: {}, current_user:)
          @params = params
          @current_user = current_user
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def execute
          authorize!

          segment = Analytics::DevopsAdoption::Segment.find_by(namespace_id: namespace.id, display_namespace_id: namespace.id)

          if segment
            ServiceResponse.success(payload: { segment: segment })
          else
            create_service.execute
          end
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def authorize!
          create_service.authorize!
        end

        private

        attr_reader :params, :current_user

        def namespace
          params[:namespace]
        end

        def create_service
          @create_service ||= CreateService.new(current_user: current_user, params: params)
        end
      end
    end
  end
end
