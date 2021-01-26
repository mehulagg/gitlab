# frozen_string_literal: true

# Given a group (exportable), this class can import the
# group wiki repository for the main group and all its
# descendants.
module Groups
  module ImportExport
    class GroupWikisRepoRestorer
      attr_reader :group, :shared

      def initialize(group:, shared:)
        @group = group
        @shared = shared
      end

      def restore
        return false unless restore_root_group_wiki_repo

        group.descendants.find_each.all? do |subgroup|
          bundle_path = ::Gitlab::ImportExport.group_wiki_repo_bundle_path(shared, subgroup, ancestor_path)

          ::Gitlab::ImportExport::RepoRestorer.new(
            path_to_bundle: bundle_path,
            shared: shared,
            importable: GroupWiki.new(subgroup)).restore
        end
      end

      private

      def restore_root_group_wiki_repo
        ::Gitlab::ImportExport::RepoRestorer.new(
          path_to_bundle: ::Gitlab::ImportExport.group_wiki_repo_bundle_path(shared, group),
          shared: shared,
          importable: GroupWiki.new(group)).restore
      end

      def ancestor_path
        @ancestor_path ||= group.full_path
      end
    end
  end
end
