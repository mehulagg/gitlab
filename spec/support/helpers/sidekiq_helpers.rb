# frozen_string_literal: true

module SidekiqHelpers
  def perform_enqueued_jobs
    Sidekiq::Testing.inline! { yield }
  end
end
