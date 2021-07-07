# frozen_string_literal: true

module EE
  module BuildFinishedWorker
    def process_build(build)
      unless ::Feature.enabled?(:cancel_pipelines_prior_to_destroy, default_enabled: :yaml)
        ::Ci::Minutes::UpdateBuildMinutesService.new(build.project, nil).execute(build)
        # We need to use `reset` on `project` because their AR associations have been cached
        # and `Namespace#namespace_statistics` will return stale data.
        ::Ci::Minutes::EmailNotificationService.new(build.project.reset).execute if ::Gitlab.com?
      end

      RequirementsManagement::ProcessRequirementsReportsWorker.perform_async(build.id)

      super
    end
  end
end
