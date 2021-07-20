# frozen_string_literal: true

# Given a group, this class can import the
# wiki repositories for the main group and all its
# descendants.
#
# If we want to import more group repositories in the future
# we should extend this class.
module Gitlab
  module ImportExport
    module Group
      class GroupAndDescendantsRepoRestorer
        attr_reader :group, :shared, :tree_restorer

        def initialize(group:, shared:, tree_restorer:)
          @group = group
          @shared = shared
          @tree_restorer = tree_restorer
        end

        def restore
          # At the moment, group only have wiki repositories so, in order
          # to avoid iterating them, we're checking the feature flag before
          # the loop.
          #
          # If, at some point, we add more repositories to groups, we should
          # move this check inside the loop, along with the other checks
          # for the new repository type.
          return true unless group.licensed_feature_available?(:group_wikis)
          return true if group_mapping.empty?

          group.self_and_descendants.find_each.all? do |subgroup|
            old_id = group_mapping[subgroup]

            next true unless old_id

            restore_wiki(subgroup, old_id)
          end
        end

        private

        def group_mapping
          @group_mapping ||= tree_restorer.groups_mapping.invert
        end

        def restore_wiki(group, old_id)
          ::Gitlab::ImportExport::RepoRestorer.new(
            path_to_bundle: ::Gitlab::ImportExport.group_wiki_repo_bundle_full_path(shared, old_id),
            shared: shared,
            importable: GroupWiki.new(group)).restore
        end
      end
    end
  end
end
