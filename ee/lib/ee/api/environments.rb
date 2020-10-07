# frozen_string_literal: true

module EE
  module API
    module Environments
      extend ActiveSupport::Concern

      prepended do
        desc 'Updates a canary track of an existing environment' do
          detail 'This feature was introduced in GitLab 8.11.'
          success Entities::Environment
        end
        params do
          requires :environment_id, type: Integer,  desc: 'The environment ID'
          optional :weight,         type: Integer,  desc: 'The canary weight for the canary track',
                                    values: 0..100
        end
        put ':id/environments/:environment_id/canary' do
          params = declared_params(include_missing: false)
  
          environment = user_project.environments.find!(params[:environment_id])
  
          result = EE::Environments::UpdateCanaryService
            .new(user_project, current_user, params)
            .execute(environment)
  
          if result[:status] == :success
            present result[:environment], with: Entities::Environment, current_user: current_user
          else
            render_api_error!(result[:message], result[:http_status])
          end
        end
      end
    end
  end
end
