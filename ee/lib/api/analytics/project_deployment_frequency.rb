# frozen_string_literal: true

module API
  module Analytics
    class ProjectDeploymentFrequency < ::API::Base
      include Gitlab::Utils::StrongMemoize
      include PaginationParams

      feature_category :planning_analytics

      before do
        authenticate!
      end

      params do
        requires :id, type: String, desc: 'The ID of the project'
      end

      resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
        namespace ':id/analytics' do
          desc 'List analytics for the project'

          params do
            requires :environment, type: String, desc: 'Name of the environment to filter by'
            requires :from, type: DateTime, desc: 'Datetime to start from, inclusive'
            optional :to, type: DateTime, desc: 'Datetime to end at, exclusive'
            optional :interval, type: String, desc: 'Interval to roll-up data by',
                     values: Analytics::Deployments::Frequency::AggregateService::VALID_INTERVALS
          end

          get 'deployment_frequency' do
            result = Analytics::Deployments::Frequency::AggregateService
              .new(container: user_project, current_user: current_user, **declared_params(include_missing: false))
              .execute

            unless result[:status] == :success
              error!(result[:message], result[:http_status])
            end

            present result[:frequencies], with: EE::API::Entities::Analytics::DeploymentFrequency
          end
        end
      end
    end
  end
end
