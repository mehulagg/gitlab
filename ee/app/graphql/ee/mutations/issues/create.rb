# frozen_string_literal: true

module EE
  module Mutations
    module Issues
      module Create
        extend ActiveSupport::Concern

        prepended do
          include ::Mutations::Issues::CommonEEMutationArguments

          argument :epic_id, ::Types::GlobalIDType[::Epic],
                   required: false,
                   description: 'The ID of an epic to associate the issue with.'
        end

        private

        def create_issue_params(params)
          params[:epic_id] &&= params[:epic_id]&.model_id

          super(params)
        end
      end
    end
  end
end
