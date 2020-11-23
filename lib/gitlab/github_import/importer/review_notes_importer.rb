# frozen_string_literal: true

module Gitlab
  module GithubImport
    module Importer
      class ReviewNotesImporter
        include ParallelScheduling

        def representation_class
          Representation::ReviewNote
        end

        def importer_class
          ReviewNoteImporter
        end

        def sidekiq_worker_class
          ImportReviewNoteWorker
        end

        def collection_method
          :pull_requests_reviews
        end

        def id_for_already_imported_cache(review)
          review.id
        end
      end
    end
  end
end
