# frozen_string_literal: true

module EE
  module Gitlab
    module ImportExport
      module WikiRepoSaver
        extend ::Gitlab::Utils::Override

        private

        override :bundle_full_path
        def bundle_full_path
          return super unless exportable.is_a?(Group)

          ::Gitlab::ImportExport.group_wiki_repo_bundle_path(shared, bundle_filename)
        end

        override :bundle_filename
        def bundle_filename
          return super unless exportable.is_a?(Group)

          ::Gitlab::ImportExport.group_wiki_repo_bundle_filename(exportable.id)
        end
      end
    end
  end
end
