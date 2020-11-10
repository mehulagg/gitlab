# frozen_string_literal: true

module Resolvers
  class EpicIssuesResolver < BaseResolver
    type Types::EpicIssueType.connection_type, null: true

    alias_method :epic, :object

    def resolve(**args)
      epic.issues_readable_by(context[:current_user], preload: { project: [:namespace, :project_feature] })
    end
  end
end
