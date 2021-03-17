# frozen_string_literal: true

module Iterations
  class UpdateStatusWorker
    include ApplicationWorker

    BATCH_SIZE = 1000

    idempotent!

    queue_namespace :cronjob
    feature_category :issue_tracking

    def perform
      set_started_iterations
      set_closed_iterations
    end

    private

    def set_started_iterations
      Iteration.upcoming.start_date_passed.each_batch(of: BATCH_SIZE) do |iterations|
        iterations.update_all(state_enum: ::Iteration::STATE_ENUM_MAP[:started])
      end
    end

    def set_closed_iterations
      Iteration.upcoming.or(Iteration.started).due_date_passed.each_batch(of: BATCH_SIZE) do |iterations|
        iterations.update_all(state_enum: ::Iteration::STATE_ENUM_MAP[:closed])
      end
    end
  end
end
