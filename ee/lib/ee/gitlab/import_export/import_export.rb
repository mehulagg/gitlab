# frozen_string_literal: true

module EE
  module Gitlab
    module ImportExport
      def group_wiki_repo_bundle_filename
        'group.wiki.bundle'
      end

      def group_wiki_repo_bundle_path(shared, group, root_ancestor_path = nil)
        subdir = group_wiki_subdir(group.full_path, root_ancestor_path)

        File.join(shared.export_path, 'repositories', subdir, group_wiki_repo_bundle_filename)
      end

      private

      def group_wiki_subdir(group_path, root_ancestor_path)
        return '' unless root_ancestor_path

        Pathname.new(group_path).relative_path_from(root_ancestor_path)
      end
    end
  end
end
