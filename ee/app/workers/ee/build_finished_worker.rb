# frozen_string_literal: true

module EE
  module BuildFinishedWorker
    def process_build(build)
      ::Ci::Minutes::UpdateBuildMinutesService.new(build.project, nil).execute(build)

      unless build.project.requirements.empty?
        RequirementsManagement::ProcessRequirementsReportsWorker.perform_async(build.id)
      end

      super
    end
  end
end
