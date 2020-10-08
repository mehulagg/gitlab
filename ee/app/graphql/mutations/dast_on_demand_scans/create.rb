# frozen_string_literal: true

module Mutations
  module DastOnDemandScans
    class Create < BaseMutation
      InvalidGlobalID = Class.new(StandardError)

      include AuthorizesProject

      graphql_name 'DastOnDemandScanCreate'

      field :pipeline_url, GraphQL::STRING_TYPE,
            null: true,
            description: 'URL of the pipeline that was created.'

      argument :full_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project the site profile belongs to.'

      argument :dast_site_profile_id, ::Types::GlobalIDType[::DastSiteProfile],
               required: true,
               description: 'ID of the site profile to be used for the scan.'

      argument :dast_scanner_profile_id, ::Types::GlobalIDType[::DastScannerProfile],
               required: false,
               description: 'ID of the scanner profile to be used for the scan.'

      authorize :create_on_demand_dast_scan

      def resolve(full_path:, dast_site_profile_id:, **args)
        project = authorized_find_project!(full_path: full_path)

        # TODO: remove explicit coercion once compatibility layer is removed
        # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
        dast_site_profile_id = ::Types::GlobalIDType[::DastSiteProfile].coerce_isolated_input(dast_site_profile_id)

        dast_site_profile = find_dast_site_profile(project: project, dast_site_profile_id: dast_site_profile_id)
        dast_site = dast_site_profile.dast_site
        dast_scanner_profile = find_dast_scanner_profile(project: project, dast_scanner_profile_id: args[:dast_scanner_profile_id])

        result = ::Ci::RunDastScanService.new(
          project, current_user
        ).execute(
          branch: project.default_branch,
          target_url: dast_site.url,
          spider_timeout: dast_scanner_profile&.spider_timeout,
          target_timeout: dast_scanner_profile&.target_timeout
        )

        if result.success?
          success_response(project: project, pipeline: result.payload)
        else
          error_response(result)
        end
      end

      private

      # rubocop: disable CodeReuse/ActiveRecord
      def find_dast_site_profile(project:, dast_site_profile_id:)
        DastSiteProfilesFinder.new(project_id: project.id, id: dast_site_profile_id.model_id)
          .execute
          .first!
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def find_dast_scanner_profile(project:, dast_scanner_profile_id:)
        return unless dast_scanner_profile_id

        # TODO: remove explicit coercion once compatibility layer is removed
        # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
        dast_scanner_profile_id = ::Types::GlobalIDType[::DastScannerProfile]
          .coerce_isolated_input(dast_scanner_profile_id)

        project
          .dast_scanner_profiles
          .find(dast_scanner_profile_id.model_id)
      end

      def success_response(project:, pipeline:)
        pipeline_url = Rails.application.routes.url_helpers.project_pipeline_url(
          project,
          pipeline
        )
        {
          errors: [],
          pipeline_url: pipeline_url
        }
      end

      def error_response(result)
        { errors: result.errors }
      end
    end
  end
end
