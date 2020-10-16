# frozen_string_literal: true

module Mutations
  module AlertManagement
    module PrometheusIntegration
      class ResetToken < IntegrationBase
        graphql_name 'PrometheusIntegrationResetToken'

        def resolve(args)
          project = authorized_find!(full_path: args[:project_path])
          result = ::Projects::Operations::UpdateService.new(
            project,
            current_user,
            { alerting_setting_attributes: { regenerate_token: true } }
          ).execute

          response integration(project), result
        end
      end
    end
  end
end
