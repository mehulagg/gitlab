module Ci
  class BuildRetryWorker
    include ApplicationWorker
    include PipelineQueue

    urgency :low

    idempotent!
    
    def perform(build_id)
      build = CommitStatus.find_by_id(build_id)
      return unless build && build.project

      Ci::BuildRetryService.new(build).execute
    end
  end
end