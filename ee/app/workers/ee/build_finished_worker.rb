# frozen_string_literal: true

module EE
  module BuildFinishedWorker
    def process_build(build)
      RequirementsManagement::ProcessRequirementsReportsWorker.perform_async(build.id)

      super
    end
  end
end
