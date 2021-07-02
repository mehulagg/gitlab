# frozen_string_literal: true

module EE
  module BuildFinishedWorker
    def process_build(build)
      ::Ci::Minutes::UpdateBuildMinutesService.new(build.project, nil).execute(build)
      # We need to use `reset` on `project` because their AR associations have been cached
      # and `Namespace#namespace_statistics` will return stale data.
      ::Ci::Minutes::EmailNotificationService.new(build.project.reset).execute if ::Gitlab.com?

      unless build.project.requirements.empty?
        RequirementsManagement::ProcessRequirementsReportsWorker.perform_async(build.id)
      end

      super
    end
  end
end
