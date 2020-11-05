# frozen_string_literal: true

module EE
  module API
    module BoardsResponses
      extend ActiveSupport::Concern

      prepended do
        helpers do
          # Overrides API::BoardsResponses create_list_params
          def create_list_params
            params.slice(:label_id, :milestone_id, :assignee_id)
          end

          # Overrides API::BoardsResponses authorize_list_type_resource!
          def authorize_list_type_resource!
            # rubocop: disable CodeReuse/ActiveRecord
            if params[:label_id] && !available_labels_for(board_parent).exists?(params[:label_id])
              render_api_error!({ error: 'Label not found!' }, 400)
            end
            # rubocop: enable CodeReuse/ActiveRecord

            if params[:milestone_id]
              milestones = ::Boards::MilestonesFinder.new(board, current_user).execute

              unless milestones.id_in(params[:milestone_id]).exists?
                render_api_error!({ error: 'Milestone not found!' }, 400)
              end
            end

            if params[:assignee_id]
              users = ::Boards::UsersFinder.new(board, current_user).execute

              unless users.with_user(params[:assignee_id]).exists?
                render_api_error!({ error: 'User not found!' }, 400)
              end
            end
          end

          # Overrides API::BoardsResponses list_creation_params
          params :list_creation_params do
            optional :label_id, type: Integer, desc: 'The ID of an existing label'
            optional :milestone_id, type: Integer, desc: 'The ID of an existing milestone'
            optional :assignee_id, type: Integer, desc: 'The ID of an assignee'
            exactly_one_of :label_id, :milestone_id, :assignee_id
          end

          # Overrides API::BoardsResponses update_params
          params :update_params do
            optional :name, type: String, desc: 'The board name'
            optional :assignee_id, type: Integer, desc: 'The ID of a user to associate with board'
            optional :milestone_id, type: Integer, desc: 'The ID of a milestone to associate with board'
            optional :labels, type: String, desc: 'Comma-separated list of label names'
            optional :weight, type: Integer, desc: 'The weight of the board'
          end
        end
      end
    end
  end
end
