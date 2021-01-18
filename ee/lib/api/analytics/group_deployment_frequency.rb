# frozen_string_literal: true

module API
  module Analytics
    class GroupDeploymentFrequency < ::API::Base
      feature_category :continuous_delivery

      before do
        authenticate!
      end

      params do
        requires :id, type: String, desc: 'The ID of the group'
      end

      resource :groups, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
        namespace ':id/analytics' do
          desc 'List deployment fequencies for the group'

          params do
            requires :environment, type: String, desc: 'Name of the environment to filter by'
            requires :from, type: DateTime, desc: 'Datetime to start from, inclusive'
            optional :to, type: DateTime, desc: 'Datetime to end at, exclusive'
            optional :interval, type: String, desc: 'Interval to roll-up data by'
          end

          get 'deployment_frequency' do
            result = ::Analytics::Deployments::Frequency::AggregateService
              .new(container: user_group,
                   current_user: current_user,
                   params: declared_params(include_missing: false))
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
