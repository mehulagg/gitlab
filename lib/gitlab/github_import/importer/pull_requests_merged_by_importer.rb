# frozen_string_literal: true

module Gitlab
  module GithubImport
    module Importer
      class PullRequestsMergedByImporter
        include ParallelScheduling

        def importer_class
          PullRequestMergedByImporter
        end

        def representation_class
          Gitlab::GithubImport::Representation::PullRequest
        end

        def sidekiq_worker_class
          ImportPullRequestMergedByWorker
        end

        def collection_method
          :pull_requests_merged_by
        end

        def id_for_already_imported_cache(merge_request)
          merge_request.id
        end

        def each_object_to_import
          merge_requests_to_import.find_each do |merge_request|
            pull_request = client.pull_request(project.import_source, merge_request.iid)
            yield(pull_request)

            mark_as_imported(merge_request)
          end
        end

        private

        def merge_requests_to_import
          project
            .merge_requests
            .where.not(id: already_imported_merge_requests)
            .with_state(:merged)
        end

        def already_imported_merge_requests
          Gitlab::Cache::Import::Caching.set_values(already_imported_cache_key)
        end
      end
    end
  end
end
