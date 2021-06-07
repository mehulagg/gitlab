# frozen_string_literal: true

module Mutations
  module Pipelines
    class RunDastScan < BaseMutation
      include FindsProject

      graphql_name 'RunDASTScan'

      field :pipeline_url, GraphQL::STRING_TYPE,
            null: true,
            description: 'URL of the pipeline that was created.'

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project the DAST scan belongs to.'

      argument :target_url, GraphQL::STRING_TYPE,
               required: true,
               description: 'The URL of the target to be scanned.'

      argument :branch, GraphQL::STRING_TYPE,
               required: true,
               description: 'The branch to be associated with the scan.'

      argument :scan_type, Types::DastScanTypeEnum,
               required: true,
               description: 'The type of scan to be run.'

      authorize :create_on_demand_dast_scan

      def resolve(project_path:, target_url:, branch:, scan_type:)
        project = authorized_find!(project_path)

        result = ::DastOnDemandScans::CreateService.new(
          container: project,
          current_user: current_user,
          params: {
            branch: branch,
            dast_site_profile: DastSiteProfile.new(dast_site: DastSite.new(url: target_url))
          }
        ).execute

        if result.success?
          success_response(project: project, pipeline: result.payload[:pipeline])
        else
          error_response(result.message)
        end
      end

      private

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

      def error_response(message)
        { errors: [message] }
      end
    end
  end
end
