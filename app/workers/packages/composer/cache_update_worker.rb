# frozen_string_literal: true

module Packages
  module Composer
    class CacheUpdateWorker
      include ApplicationWorker
      include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

      feature_category :package_registry

      idempotent!

      def perform(project_id, package_name, last_page_sha)
        project = Project.find_by_id(project_id)

        return unless project

        Gitlab::Composer::Cache.new(project: project, name: package_name, last_page_sha: last_page_sha).execute
      rescue => e
        Gitlab::ErrorTracking.log_exception(e, project_id: project_id)
      end
    end
  end
end
