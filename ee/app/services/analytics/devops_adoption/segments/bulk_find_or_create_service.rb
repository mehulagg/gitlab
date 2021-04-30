# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Segments
      class BulkFindOrCreateService
        def initialize(params: {}, current_user:)
          @params = params
          @current_user = current_user
        end

        def execute
          authorize!

          segments = services.map do |service|
            service.execute.payload[:segment]
          end

          ServiceResponse.success(payload: { segments: segments })
        end

        def authorize!
          services.each(&:authorize!)
        end

        private

        attr_reader :params, :current_user

        def services
          @services ||= params[:namespaces].map do |namespace|
            FindOrCreateService.new(current_user: current_user,
                                    params: { namespace: namespace, display_namespace: namespace })
          end
        end
      end
    end
  end
end
