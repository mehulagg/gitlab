# frozen_string_literal: true

module Gitlab
  module GithubImport
    module Importer
      class DiffNotesImporter
        include ParallelScheduling

        def representation_class
          Representation::DiffNote
        end

        def importer_class
          DiffNoteImporter
        end

        def sidekiq_worker_class
          ImportDiffNoteWorker
        end

        def collection_method
          :pull_requests_comments
        end

        def id_for_already_fetched_cache(note)
          note.id
        end
      end
    end
  end
end
