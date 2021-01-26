# frozen_string_literal: true

module EE
  module Gitlab
    module ImportExport
      module WikiRepoSaver
        extend ::Gitlab::Utils::Override

        private

        override :bundle_filename
        def bundle_filename
          if exportable.is_a?(Group)
            'group.wiki.bundle' #::Gitlab::ImportExport.group_wiki_repo_bundle_filename
          else
            super
          end
        end
      end
    end
  end
end
