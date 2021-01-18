# frozen_string_literal: true

module API
  module Analytics
    class ProjectLeadTime < ::API::Base
      feature_category :continuous_delivery

      before do
        authenticate!
      end

      params do
        requires :id, type: String, desc: 'The ID of the project'
      end

      resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
        namespace ':id/analytics' do
          desc 'List merge request lead times for the project'

          params do
            requires :from, type: DateTime, desc: 'Datetime to start from, inclusive'
            optional :to, type: DateTime, desc: 'Datetime to end at, exclusive'
            optional :interval, type: String, desc: 'Interval to roll-up data by'
          end

          get 'lead_time' do
            result = ::Analytics::MergeRequests::LeadTime::AggregateService
              .new(container: user_project,
                   current_user: current_user,
                   params: declared_params(include_missing: false))
              .execute

            unless result[:status] == :success
              render_api_error!(result[:message], result[:http_status])
            end

            present result[:lead_times], with: EE::API::Entities::Analytics::LeadTime
          end
        end
      end
    end
  end
end
