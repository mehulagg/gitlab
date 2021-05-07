# frozen_string_literal: true

module EE
  module Gitlab
    module ImportExport
      module RepoRestorer
        extend ::Gitlab::Utils::Override

        private

        override :update_importable_repository_info
        def update_importable_repository_info
          return super unless importable.is_a?(GroupWiki)

          # At this point, the repo has been created but we
          # need to track the repository shard instantiated
          # inside the repository object.
          importable.track_wiki_repository(repository.shard)
        end
      end
    end
  end
end
