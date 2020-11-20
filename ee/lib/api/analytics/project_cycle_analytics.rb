# frozen_string_literal: true

module API
  module Analytics
    class ProjectCycleAnalytics < ::API::Base
      feature_category :planning_analytics

      before do
        authenticate!
      end

      helpers do
        def project
          @project ||= find_project!(params[:project_id])
        end
      end

      resource :analytics do
        desc 'List cycle analytics information about project'
        params do
          requires :project_id, type: Integer, desc: 'Project ID'
          # TODO: Optional parameter: rollup interval? Default: 30 Days
          use :pagination
        end

        get 'deployment_frequency' do
          authorize! :read_project_cycle_analytics, project

          # TODO: Collect Deployment Frequency Data.
          #       Is it possible to leverage
          #         ee/lib/gitlab/analytics/cycle_analytics/
          #         summary/group/deployment_frequency.rb
          #       to do this?

          # TODO: Rollup the data by the given interval, default 30 days.

          data = []
          deployment_frequencies = paginate(data)

          present deployment_frequencies,
                  with: EE::API::Entities::Analytics::Cycle::DeploymentFrequency,
                  current_user: current_user,
                  issuable_metadata: Gitlab::IssuableMetadata.new(current_user, deployment_frequencies).data
        end
      end
    end
  end
end
