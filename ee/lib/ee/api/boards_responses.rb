# frozen_string_literal: true

module EE
  module API
    module BoardsResponses
      extend ActiveSupport::Concern

      prepended do
        helpers do
          # Overrides API::BoardsResponses create_list_params
          def create_list_params
            params.slice(:label_id, :milestone_id, :assignee_id, :iteration_id).tap do |p|
              p.delete(:iteration_id) unless ::Feature.enabled?(:iteration_board_lists, board_parent)
            end
          end

          # Overrides API::BoardsResponses list_creation_params
          params :list_creation_params do
            optional :label_id, type: Integer, desc: 'The ID of an existing label'
            optional :milestone_id, type: Integer, desc: 'The ID of an existing milestone'
            optional :iteration_id, type: Integer, desc: 'The ID of an assignee iteration'
            optional :assignee_id, type: Integer, desc: 'The ID of an assignee'
            exactly_one_of :label_id, :milestone_id, :iteration_id, :assignee_id
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
