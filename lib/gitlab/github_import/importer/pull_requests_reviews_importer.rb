# frozen_string_literal: true

module Gitlab
  module GithubImport
    module Importer
      class PullRequestsReviewsImporter
        include ParallelScheduling

        def initialize(...)
          super

          @merge_request_already_imported_cache_key =
            "github-importer/merge_request/already-imported/#{project.id}"
        end

        def importer_class
          PullRequestReviewImporter
        end

        def representation_class
          Gitlab::GithubImport::Representation::PullRequestReview
        end

        def sidekiq_worker_class
          ImportPullRequestReviewWorker
        end

        def collection_method
          :pull_request_reviews
        end

        def id_for_already_imported_cache(review)
          review.id
        end

        # Because the worker can be interrupted, by rate limit for instance,
        # - before importing all reviews of a merge request OR
        # - before importing all merge requests reviews
        #
        # There's two layers of caching here:
        # - Merge requests
        # - Reviews
        #
        # Besides that, ParallelScheduling#each_object_to_import only does API
        # calls related only to the project, therefore we need to override it to
        # do the call passing the project (repo) and the pull_request id.
        def each_object_to_import
          each_merge_request_to_import do |merge_request|
            repo = project.import_source
            options = collection_options.merge(page: page_counter.current)

            client.each_page(collection_method, repo, merge_request.iid, options) do |page|
              next unless page_counter.set(page.number)

              page.objects.each do |object|
                next if already_imported?(object)

                yield object

                mark_as_imported(object)
              end
            end
          end
        end

        private

        def each_merge_request_to_import
          project.merge_requests.find_each do |merge_request|
            next if reviews_already_imported_for_merge_request?(merge_request)

            yield merge_request

            mark_merge_request_reviews_imported(merge_request)
          end
        end

        def mark_merge_request_reviews_imported(merge_request)
          Gitlab::Cache::Import::Caching.set_add(
            @merge_request_already_imported_cache_key,
            merge_request.id
          )
        end

        def reviews_already_imported_for_merge_request?(merge_request)
          Gitlab::Cache::Import::Caching.set_includes?(
            @merge_request_already_imported_cache_key,
            merge_request.id
          )
        end
      end
    end
  end
end
