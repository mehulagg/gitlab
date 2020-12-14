# frozen_string_literal: true

module Resolvers
  class ExternalIssueResolver < BaseResolver
    description 'Retrieve a single issue from external tracker'

    type Types::ExternalIssueType, null: true

    def resolve
      BatchLoader::GraphQL.for(object.external_issue_key).batch(key: object.external_type) do |external_issue_keys, loader, args|
        case args[:key]
        when 'jira'
          jira_issues(external_issue_keys).each do |external_issue|
            loader.call(
              external_issue.id,
              ::Integrations::Jira::IssueSerializer.new.represent(external_issue, project: object.vulnerability.project)
            )
          end
        end
      end
    end

    private

    def jira_issues(issue_ids)
      result = ::Projects::Integrations::Jira::ByIdsFinder.new(object.vulnerability.project, issue_ids).execute
      return [] if result.nil?

      raise GraphQL::ExecutionError, result[:error] if result[:error].present?

      result[:issues]
    end
  end
end
