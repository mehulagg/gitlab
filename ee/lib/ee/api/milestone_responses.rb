# frozen_string_literal: true

module EE
  module API
    module MilestoneResponses
      extend ActiveSupport::Concern

      included do
        helpers do
          def milestone_burndown_events_for(parent)
            milestone = parent.milestones.find(params[:milestone_id])

            if milestone.supports_milestone_charts?
              issues = milestone.issues_visible_to_user(current_user)
              present Burndown.new(issues, milestone.start_date, milestone.due_date).as_json
            else
              render_api_error!("Milestone does not support burndown chart", 405)
            end
          end
        end
      end
    end
  end
end
