# frozen_string_literal: true

module EE
  module Git
    module WikiPushService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute
        super

        # TODO: Support Elasticsearch indexing for group wikis
        # https://gitlab.com/gitlab-org/gitlab/-/issues/207889
        return unless wiki.is_a?(::ProjectWiki)
        return unless wiki.container.use_elasticsearch?
        return unless default_branch_changes.any?

        wiki.index_wiki_blobs
      end
    end
  end
end
