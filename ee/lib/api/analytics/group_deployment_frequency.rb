# frozen_string_literal: true

module API
  module Analytics
    class GroupDeploymentFrequency < ::API::Base
      feature_category :continuous_delivery

      before do
        authenticate!
        not_found! unless ::Feature.enabled?(:dora4_group_deployment_frequency_api, user_group)
      end

      params do
        requires :id, type: String, desc: 'The ID of the group'
      end

      resource :groups, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
        namespace ':id/analytics' do
          desc 'List deployment frequencies for the group'

          params do
            requires :environment, type: String, desc: 'The name of the environment to filter by'
            requires :from, type: DateTime, desc: 'Datetime range to start from. Inclusive, ISO 8601 format (`YYYY-MM-DDTHH:MM:SSZ`)'
            optional :to, type: DateTime, desc: 'Datetime range to end at. Exclusive, ISO 8601 format (`YYYY-MM-DDTHH:MM:SSZ`)'
            optional :interval, type: String, desc: 'The bucketing interval (`all`, `monthly`, `daily`)'
          end

          get 'deployment_frequency' do
            result = ::Analytics::Deployments::Frequency::AggregateService
              .new(container: user_group,
                   current_user: current_user,
                   params: declared_params(include_missing: false))
              .execute

            unless result[:status] == :success
              render_api_error!(result[:message], result[:http_status])
            end

            present result[:frequencies], with: EE::API::Entities::Analytics::DeploymentFrequency
          end
        end
      end
    end
  end
end
