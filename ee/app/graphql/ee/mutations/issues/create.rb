# frozen_string_literal: true

module EE
  module Mutations
    module Issues
      module Create
        extend ActiveSupport::Concern

        prepended do
          argument :weight, GraphQL::INT_TYPE,
                   required: false,
                   description: 'The weight of the issue'
          argument :epic_id, ::Types::GlobalIDType[::Epic],
                   required: false,
                   description: 'The ID of an epic to associate the issue with'
        end

        private

        def create_issue_params(params)
          params[:epic_id] &&= ::GitlabSchema.parse_gid(params[:epic_id], expected_type: ::Epic).model_id

          super(params)
        end
      end
    end
  end
end
