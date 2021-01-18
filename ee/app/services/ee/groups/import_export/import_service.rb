# frozen_string_literal: true

module EE
  module Groups
    module ImportExport
      module ImportService
        extend ::Gitlab::Utils::Override

        override :restorers
        def restorers
          super << wiki_restorer
        end

        def wiki_restorer
          ::Gitlab::ImportExport::RepoRestorer.new(path_to_bundle: wiki_repo_path,
                                                   shared: shared,
                                                   exportable: GroupWiki.new(group))
        end

        def wiki_repo_path
          File.join(shared.export_path, ::Gitlab::ImportExport.group_wiki_repo_bundle_filename)
        end
      end
    end
  end
end
