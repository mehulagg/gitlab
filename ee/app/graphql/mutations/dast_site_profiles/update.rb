# frozen_string_literal: true

module Mutations
  module DastSiteProfiles
    class Update < BaseMutation
      include FindsProject

      graphql_name 'DastSiteProfileUpdate'

      SiteProfileID = ::Types::GlobalIDType[::DastSiteProfile]

      field :id, SiteProfileID,
            null: true,
            description: 'ID of the site profile.'

      argument :full_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project the site profile belongs to.'

      argument :id, SiteProfileID,
               required: true,
               description: 'ID of the site profile to be updated.'

      argument :profile_name, GraphQL::STRING_TYPE,
               required: true,
               description: 'The name of the site profile.'

      argument :target_url, GraphQL::STRING_TYPE,
               required: false,
               description: 'The URL of the target to be scanned.'

      argument :excluded_urls, [GraphQL::STRING_TYPE],
               required: false,
               description: 'The URLs to skip during an authenticated scan. Will be ignored ' \
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

      def resolve(full_path:, id:, profile_name:, target_url: nil, excluded_urls: nil, request_headers: nil, auth: nil)
        project = authorized_find!(full_path)

        # TODO: remove explicit coercion once compatibility layer has been removed
        # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
        params = {
          id: SiteProfileID.coerce_isolated_input(id).model_id,
          name: profile_name,
          target_url: target_url,
          excluded_urls: feature_flagged_excluded_urls(project, excluded_urls)
        }.compact

        result = ::DastSiteProfiles::UpdateService.new(project, current_user).execute(**params)

        if result.success?
          { id: result.payload.to_global_id, errors: [] }
        else
          { errors: result.errors }
        end
      end

      private

      def feature_flagged_excluded_urls(project, excluded_urls)
        return unless Feature.enabled?(:security_dast_site_profiles_additional_fields, project, default_enabled: :yaml)

        excluded_urls
      end
    end
  end
end
