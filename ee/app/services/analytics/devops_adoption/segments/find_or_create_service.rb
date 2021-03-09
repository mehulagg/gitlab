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

        def execute
          authorize!

          segment = Analytics::DevopsAdoption::Segment.find_by_namespace_id(namespace_id)

          if segment
            ServiceResponse.success(payload: { segment: segment })
          else
            CreateService.new(current_user: current_user, params: params).execute
          end
        end

        private

        attr_reader :params, :current_user

        def namespace_id
          params.fetch(:namespace_id, params[:namespace]&.id)
        end
      end
    end
  end
end
