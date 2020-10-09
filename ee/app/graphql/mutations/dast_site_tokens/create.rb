# frozen_string_literal: true

module Mutations
  module DastSiteTokens
    class Create < BaseMutation
      include AuthorizesProject

      graphql_name 'DastSiteTokenCreate'

      field :id, ::Types::GlobalIDType[::DastSiteToken],
            null: true,
            description: 'ID of the site token.'

      field :token, GraphQL::STRING_TYPE,
            null: true,
            description: 'Token string.'

      field :status, Types::DastSiteProfileValidationStatusEnum,
            null: true,
            description: 'The current validation status of the target.'

      argument :full_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project the site token belongs to.'

      argument :target_url, GraphQL::STRING_TYPE,
               required: false,
               description: 'The URL of the target to be validated.'

      authorize :create_on_demand_dast_scan

      def resolve(full_path:, target_url:)
        project = authorized_find_project!(full_path: full_path)
        raise Gitlab::Graphql::Errors::ResourceNotAvailable, 'Feature disabled' unless allowed?(project)

        dast_site_token = DastSiteToken.new(project: project, token: SecureRandom.uuid, url: target_url)

        if dast_site_token.save
          url_base = normalize_target_url(target_url)
          dast_site_validation = find_dast_site_validation(project, url_base)
          status = calculate_status(dast_site_validation)

          success_response(dast_site_token, status)
        else
          error_response(dast_site_token)
        end
      end

      private

      def allowed?(project)
        Feature.enabled?(:security_on_demand_scans_site_validation, project)
      end

      def normalize_target_url(target_url)
        DastSiteValidation.get_normalized_url_base(target_url)
      end

      def find_dast_site_validation(project, url_base)
        DastSiteValidationsFinder.new(project_id: project.id, url_base: url_base).execute.first
      end

      def calculate_status(dast_site_validation)
        state = dast_site_validation&.state || DastSiteValidation::INITIAL_STATE

        "#{state}_VALIDATION".upcase
      end

      def success_response(dast_site_token, status)
        { errors: [], id: dast_site_token.to_global_id, status: status, token: dast_site_token.token }
      end

      def error_response(dast_site_token)
        { errors: dast_site_token.errors.full_messages }
      end
    end
  end
end
