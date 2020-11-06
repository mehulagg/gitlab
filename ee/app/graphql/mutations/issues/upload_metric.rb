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

      authorize :upload_metric

      MAX_FILE_SIZE = 1.megabyte

      def resolve(project_path:, iid:, file:, url: nil)
        return response('File size too large!') if file.size > MAX_FILE_SIZE

        @issue = authorized_find!(project_path: project_path, iid: iid)

        upload = ::IncidentManagement::Incidents::UploadMetricService.new(
          issue,
          current_user,
          { file: file, url: url }
        ).execute

        response(error_message(upload))
      end

      private

      attr_reader :issue

      def response(errors)
        {
          issue: issue,
          errors: Array(errors)
        }
      end

      def error_message(upload)
        return unless upload[:status] == :error

        upload[:message]
      end
    end
  end
end
