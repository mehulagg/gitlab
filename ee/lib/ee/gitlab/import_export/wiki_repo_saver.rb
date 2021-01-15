# frozen_string_literal: true

module EE
  module Gitlab
    module ImportExport
      module WikiRepoSaver
        extend ::Gitlab::Utils::Override

        private

        override :repository
        def bundle_filename
          if exportable.is_a?(Group)
            ::Gitlab::ImportExport.group_wiki_repo_bundle_filename
          else
            super
          end
        end
      end
    end
  end
end
