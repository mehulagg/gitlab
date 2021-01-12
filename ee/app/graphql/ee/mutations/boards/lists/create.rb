# frozen_string_literal: true

module EE
  module Mutations
    module Boards
      module Lists
        module Create
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          prepended do
            argument :milestone_id, ::Types::GlobalIDType[::Milestone],
                     required: false,
                     description: 'Global ID of an existing milestone.'
            argument :iteration_id, ::Types::GlobalIDType[::Iteration],
                     required: false,
                     description: 'Global ID of an existing iteration.'
            argument :assignee_id, ::Types::GlobalIDType[::User],
                     required: false,
                     description: 'Global ID of an existing user.'
          end

          private

          override :create_list_params
          def create_list_params(args)
            params = super

            params[:milestone_id] &&= ::GitlabSchema.parse_gid(params[:milestone_id], expected_type: ::Milestone).model_id
            params[:iteration_id] &&= ::GitlabSchema.parse_gid(params[:iteration_id], expected_type: ::Iteration).model_id
            params[:assignee_id] &&= ::GitlabSchema.parse_gid(params[:assignee_id], expected_type: ::User).model_id

            params
          end

          override :mutually_exclusive_args
          def mutually_exclusive_args
            super + [:milestone_id, :iteration_id, :assignee_id]
          end
        end
      end
    end
  end
end
