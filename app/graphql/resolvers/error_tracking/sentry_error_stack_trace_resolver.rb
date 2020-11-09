# frozen_string_literal: true

module Resolvers
  module ErrorTracking
    class SentryErrorStackTraceResolver < BaseResolver
      ErrorID = ::Types::GlobalIDType[::Gitlab::ErrorTracking::DetailedError]

      argument :id, ErrorID.to_non_null_type,
                required: true,
                description: 'ID of the Sentry issue'

      def resolve(**args)
        id = ErrorID.coerce_isolated_input(args[:id])
        issue_id = GlobalID.parse(id)&.model_id

        # Get data from Sentry
        response = ::ErrorTracking::IssueLatestEventService.new(
          project,
          current_user,
          { issue_id: issue_id }
        ).execute

        event = response[:latest_event]
        event.gitlab_project = project if event

        event
      end

      private

      def project
        return object.gitlab_project if object.respond_to?(:gitlab_project)

        object
      end
    end
  end
end
