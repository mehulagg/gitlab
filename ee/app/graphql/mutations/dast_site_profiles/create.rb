# frozen_string_literal: true

module Mutations
  module DastSiteProfiles
    class Create < BaseMutation
      include FindsProject

      graphql_name 'DastSiteProfileCreate'

      field :id, ::Types::GlobalIDType[::DastSiteProfile],
            null: true,
            description: 'ID of the site profile.'

      argument :full_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project the site profile belongs to.'

      argument :profile_name, GraphQL::STRING_TYPE,
               required: true,
               description: 'The name of the site profile.'

      argument :target_url, GraphQL::STRING_TYPE,
               required: false,
               description: 'The URL of the target to be scanned.'

      argument :excluded_urls, [GraphQL::STRING_TYPE],
               required: false,
               default_value: [],
               description: 'The URLs to skip during an authenticated scan. Defaults to `[]`. Will be ignored ' \
                            'if `security_dast_site_profiles_additional_fields` feature flag is disabled.'

      argument :request_headers, GraphQL::STRING_TYPE,
               required: false,
               description: 'Comma-separated list of request header names and values to be ' \
                            'added to every request made by DAST. Will be ignored ' \
                            'if `security_dast_site_profiles_additional_fields` feature flag is disabled.'

      argument :auth, ::Types::Dast::SiteProfileAuthInputType,
               required: false,
               description: 'Parameters for authentication. Will be ignored ' \
                            'if `security_dast_site_profiles_additional_fields` feature flag is disabled.'

      authorize :create_on_demand_dast_scan

      def resolve(full_path:, profile_name:, target_url: nil, excluded_urls: [], request_headers: nil, auth: nil)
        project = authorized_find!(full_path)

        service = ::DastSiteProfiles::CreateService.new(project, current_user)
        result = service.execute(
          name: profile_name,
          target_url: target_url,
          excluded_urls: feature_flagged_excluded_urls(project, excluded_urls)
        )

        if result.success?
          { id: result.payload.to_global_id, errors: [] }
        else
          { errors: result.errors }
        end
      end

      private

      def feature_flagged_excluded_urls(project, excluded_urls)
        return [] unless Feature.enabled?(:security_dast_site_profiles_additional_fields, project, default_enabled: :yaml)

        excluded_urls
      end
    end
  end
end
