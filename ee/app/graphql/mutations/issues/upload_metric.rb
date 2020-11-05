# frozen_string_literal: true

module Mutations
  module Issues
    class UploadMetric < ::Mutations::Issues::Base
      graphql_name 'IssueUploadMetric'

      argument :file, ApolloUploadServer::Upload,
               required: true,
               description: 'The desired weight for the issue'

      argument :url,
               GraphQL::STRING_TYPE,
               required: false,
               description: 'The URL of the metric data source'


      def resolve(project_path:, iid:, file:, url: nil)
        issue = authorized_find!(project_path: project_path, iid: iid)
        project = issue.project

        upload = ::IncidentManagement::Incidents::UploadMetricService.new(
          issue,
          current_user,
          { file: file, url: url }
        ).execute

        {
          issue: issue,
          errors: Array(error_message(upload))
        }
      end

      private

      def error_message(upload)
        return unless upload[:status] == :error

        upload[:message]
      end
    end
  end
end
