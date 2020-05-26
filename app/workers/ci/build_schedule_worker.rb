# frozen_string_literal: true

module Ci
  class BuildScheduleWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include PipelineQueue

    queue_namespace :pipeline_processing
    feature_category :continuous_integration
    worker_resource_boundary :cpu
    tags :no_disk_io

    def perform(build_id)
      ::Ci::Build.find_by_id(build_id).try do |build|
        break unless build.scheduled?

        Ci::RunScheduledBuildService
          .new(build.project, build.user).execute(build)
      end
    end
  end
end
