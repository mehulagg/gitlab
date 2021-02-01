# frozen_string_literal: true

module Packages
  module Composer
    class CacheCleanupWorker # rubocop:disable Scalability/IdempotentWorker
      include ApplicationWorker

      queue_namespace :package_repositories
      feature_category :package_registry

      def perform
        ::Packages::Composer::CacheFile.for_deletion.find_in_batches do |cache_files|
          cache_files.each(&:destroy)
        end
      rescue => e
        Gitlab::ErrorTracking.log_exception(e)
      end
    end
  end
end
