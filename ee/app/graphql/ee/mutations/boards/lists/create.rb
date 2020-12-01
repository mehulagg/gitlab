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
                     description: 'Global ID of an existing milestone'
            argument :assignee_id, ::Types::GlobalIDType[::User],
                     required: false,
                     description: 'Global ID of an existing user'
          end

          private

          override :authorize_list_type_resource!
          def authorize_list_type_resource!(board, params)
            super

            if params[:milestone_id]
              milestones = ::Boards::MilestonesFinder.new(board, current_user).execute

              unless milestones.id_in(params[:milestone_id]).exists?
                raise ::Gitlab::Graphql::Errors::ArgumentError, 'Milestone not found!'
              end
            end

            if params[:assignee_id]
              users = ::Boards::UsersFinder.new(board, current_user).execute

              unless users.with_user(params[:assignee_id]).exists?
                raise ::Gitlab::Graphql::Errors::ArgumentError, 'User not found!'
              end
            end
          end

          override :create_list_params
          def create_list_params(args)
            params = super

            params[:milestone_id] &&= ::GitlabSchema.parse_gid(params[:milestone_id], expected_type: ::Milestone).model_id
            params[:assignee_id]  &&= ::GitlabSchema.parse_gid(params[:assignee_id], expected_type: ::User).model_id

            params
          end

          override :mutually_exclusive_args
          def mutually_exclusive_args
            super + [:milestone_id, :assignee_id]
          end
        end
      end
    end
  end
end
