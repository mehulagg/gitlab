# frozen_string_literal: true

class IterationsUpdateStatusWorker
  include ApplicationWorker

  sidekiq_options retry: 3

  idempotent!

  queue_namespace :cronjob
  feature_category :issue_tracking

  def perform
    set_current_iterations
    set_closed_iterations
  end

  private

  def set_current_iterations
    Iteration
      .upcoming
      .start_date_passed
      .update_all(state_enum: ::Iteration::STATE_ENUM_MAP[:current])
  end

  def set_closed_iterations
    Iteration
      .upcoming.or(Iteration.current)
      .due_date_passed
      .update_all(state_enum: ::Iteration::STATE_ENUM_MAP[:closed])
  end
end
