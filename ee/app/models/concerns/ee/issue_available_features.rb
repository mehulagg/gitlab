# frozen_string_literal: true

module EE
  module IssueAvailableFeatures
    extend ActiveSupport::Concern

    class_methods do
      include ::Gitlab::Utils::StrongMemoize

      def available_features_for_issue_types
        strong_memoize(:available_features_for_issue_types) do
          super.merge(epics: %w(issue), sla: %w(incident))
        end
      end
    end
  end
end
