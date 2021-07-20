# frozen_string_literal: true

module IssueFeatureFlags
  class ListService < IssuableLinks::ListService
    extend ::Gitlab::Utils::Override

    private

    def child_issuables
      issuable.related_feature_flags(current_user, preload: preload_for_collection)
    end

    override :serializer
    def serializer
      Issues::LinkedIssueFeatureFlagSerializer
    end

    override :preload_for_collection
    def preload_for_collection
      [{ project: :namespace }]
    end
  end
end
