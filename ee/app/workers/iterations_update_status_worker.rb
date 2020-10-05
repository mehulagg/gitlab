# frozen_string_literal: true

class IterationsUpdateStatusWorker
  include ApplicationWorker

  idempotent!

  queue_namespace :cronjob
  feature_category :issue_tracking

  def perform
    set_started_iterations
    set_closed_iterations
  end

  private

  def set_started_iterations
    Iteration
      .upcoming
      .start_date_passed
      .update_all(state_enum: ::Iteration::STATE_ENUM_MAP[:started])
  end

  def set_closed_iterations
    Iteration
      .upcoming.or(Iteration.started)
      .due_date_passed
      .update_all(state_enum: ::Iteration::STATE_ENUM_MAP[:closed])
  end
end
