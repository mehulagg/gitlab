# frozen_string_literal: true

module Gitlab
  module ImportExport
    module GroupHelper
      def group_wiki_repo_bundle_filename(group_id)
        "#{group_id}.wiki.bundle"
      end

      def group_wiki_repo_bundle_path(shared, filename)
        File.join(shared.export_path, 'repositories', filename)
      end

      def group_wiki_repo_bundle_full_path(shared, group_id)
        group_wiki_repo_bundle_path(shared, group_wiki_repo_bundle_filename(group_id))
      end
    end
  end
end
