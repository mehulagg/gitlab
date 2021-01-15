# frozen_string_literal: true

module EE
  module Groups
    module ImportExport
      module ExportService
        extend ::Gitlab::Utils::Override

        override :savers
        def savers
          [wiki_repo_saver] + super
        end

        def wiki_repo_saver
          ::Gitlab::ImportExport::WikiRepoSaver.new(exportable: group, shared: shared)
        end
      end
    end
  end
end
