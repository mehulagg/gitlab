# frozen_string_literal: true

module EE
  module IssueAvailableFeatures
    include ::Gitlab::Utils::StrongMemoize
    extend ::Gitlab::Utils::Override

    override :available_features_for_issue_types
    def available_features_for_issue_types
      strong_memoize(:available_features_for_issue_types) do
        super.merge(epics: %w(issue))
      end
    end
  end
end
