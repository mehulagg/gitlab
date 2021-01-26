# frozen_string_literal: true

module EE
  module Groups
    module ImportExport
      module ExportService
        extend ::Gitlab::Utils::Override

        override :savers
        def savers
          super << group_and_subgroup_wikis_repo_saver
        end

        def wiki_repo_saver
          ::Gitlab::ImportExport::WikiRepoSaver.new(exportable: group, shared: shared, path_to_bundle: File.join(shared.export_path, 'repositories', 'group.wiki.bundle'))
        end

        def group_and_subgroup_wikis_repo_saver
          ::Groups::ImportExport::GroupWikisRepoSaver.new(group: group, shared: shared)
        end
      end
    end
  end
end
