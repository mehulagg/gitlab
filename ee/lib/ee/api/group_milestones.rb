# frozen_string_literal: true

module EE
  module API
    module GroupMilestones
      extend ActiveSupport::Concern

      prepended do
        include EE::API::MilestoneResponses # rubocop: disable Cop/InjectEnterpriseEditionModule

        params do
          requires :id, type: String, desc: 'The ID of a group'
        end
        resource :groups, requirements: ::API::API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
          desc 'Get a list of burndown events' do
            detail 'This feature was introduced in GitLab 12.1.'
          end
          get ':id/milestones/:milestone_id/burndown_events' do
            authorize! :read_group, user_group

            milestone_burndown_events_for(user_group)
          end
        end
      end
    end
  end
end
