# frozen_string_literal: true

# Given a group (exportable), this class can export the
# group wiki repository for the main group and all its
# descendants.
module Groups
  module ImportExport
    class GroupWikisRepoSaver
      attr_reader :group, :shared

      def initialize(group:, shared:)
        @group = group
        @shared = shared
      end

      def save
        return false unless save_root_group_wiki_repo

        group.descendants.find_each.all? do |subgroup|
          bundle_path = ::Gitlab::ImportExport.group_wiki_repo_bundle_path(shared, subgroup, ancestor_path)

          ::Gitlab::ImportExport::WikiRepoSaver.new(
            exportable: subgroup,
            shared: @shared,
            path_to_bundle: bundle_path).save
        end
      end

      private

      def save_root_group_wiki_repo
        ::Gitlab::ImportExport::WikiRepoSaver.new(
          exportable: group,
          shared: shared,
          path_to_bundle: ::Gitlab::ImportExport.group_wiki_repo_bundle_path(shared, group)).save
      end

      def ancestor_path
        @ancestor_path ||= group.full_path
      end
    end
  end
end
