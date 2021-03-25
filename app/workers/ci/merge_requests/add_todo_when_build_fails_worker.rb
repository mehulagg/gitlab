# frozen_string_literal: true
module Ci
  module MergeRequests
    class AddTodoWhenBuildFailsWorker  # rubocop:disable Scalability/IdempotentWorker
      include ApplicationWorker

      queue_namespace :ci_add_todo_when_build_fails
      urgency :high
      idempotent!

      def perform(job_id)
        job = ::CommitStatus.joins(:pipeline, :project).find(job_id)
        return unless job.failed?

        ::MergeRequests::AddTodoWhenBuildFailsService.new(job.project, nil).execute(job)
      end
    end
  end
end
