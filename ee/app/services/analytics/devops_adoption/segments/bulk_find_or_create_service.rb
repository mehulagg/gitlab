# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Segments
      class BulkFindOrCreateService
        include CommonMethods

        def initialize(params: {}, current_user:)
          @params = params
          @current_user = current_user
        end

        def execute
          authorize!

          segments = params[:namespaces].map do |namespace|
            response = FindOrCreateService
              .new(current_user: current_user, params: { namespace: namespace })
              .execute

            response.payload[:segment]
          end

          ServiceResponse.success(payload: { segments: segments })
        end

        private

        attr_reader :params, :current_user
      end
    end
  end
end
