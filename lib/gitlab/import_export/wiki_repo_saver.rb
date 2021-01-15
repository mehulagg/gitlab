# frozen_string_literal: true

module Gitlab
  module ImportExport
    class WikiRepoSaver < RepoSaver
      extend ::Gitlab::Utils::Override

      override :repository
      def repository
        @repository ||= exportable.wiki.repository
      end

      private

      override :repository
      def bundle_filename
        ::Gitlab::ImportExport.wiki_repo_bundle_filename
      end
    end
  end
end

Gitlab::ImportExport::WikiRepoSaver.prepend_if_ee('EE::Gitlab::ImportExport::WikiRepoSaver')
