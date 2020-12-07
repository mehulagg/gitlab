# frozen_string_literal: true

module EE
  module Boards
    module Lists
      module CreateService
        extend ::Gitlab::Utils::Override

        include MaxLimits

        override :type
        def type
          # We don't ever expect to have more than one list
          # type param at once.
          if params.key?('assignee_id')
            :assignee
          elsif params.key?('milestone_id')
            :milestone
          else
            super
          end
        end

        override :target
        def target(board)
          strong_memoize(:target) do
            case type
            when :assignee
              find_user(board)
            when :milestone
              find_milestone(board)
            else
              super
            end
          end
        end

        override :create_list_attributes
        def create_list_attributes(type, target, position)
          return super unless wip_limits_available?

          super.merge(
            max_issue_count: max_issue_count_by_params,
            max_issue_weight: max_issue_weight_by_params,
            limit_metric: limit_metric_by_params
          )
        end

        private

        def find_milestone(board)
          milestones = milestone_finder(board).execute
          milestones.find_by(id: params['milestone_id'])
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def find_user(board)
          user_ids = user_finder(board).execute.select(:user_id)
          ::User.where(id: user_ids).find_by(id: params['assignee_id'])
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def milestone_finder(board)
          @milestone_finder ||= ::Boards::MilestonesFinder.new(board, current_user)
        end

        def user_finder(board)
          @user_finder ||= ::Boards::UsersFinder.new(board, current_user)
        end

        def wip_limits_available?
          parent.feature_available?(:wip_limits)
        end

        def limit_metric_by_params
          params[:limit_metric]
        end
      end
    end
  end
end
