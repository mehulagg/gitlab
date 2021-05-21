# frozen_string_literal: true

class IterationsUpdateStatusWorker
  include ApplicationWorker

  sidekiq_options retry: 3
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
      iterations.update_all(state_enum: ::Iteration::STATE_ENUM_MAP[:started], updated_at: Time.current)
    end
  end

  def set_closed_iterations
    Iteration.upcoming.or(Iteration.started).due_date_passed.each_batch(of: BATCH_SIZE) do |iterations|
      closed_iteration_ids = iterations.pluck_primary_key
      iterations.update_all(state_enum: ::Iteration::STATE_ENUM_MAP[:closed], updated_at: Time.current)

      Iterations::RollOverIssuesWorker.perform_async(closed_iteration_ids)
    end
  end
end
