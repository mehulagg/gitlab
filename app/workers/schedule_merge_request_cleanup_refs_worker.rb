# frozen_string_literal: true

class ScheduleMergeRequestCleanupRefsWorker
  include ApplicationWorker
  include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

  sidekiq_options retry: 3

  feature_category :code_review
  tags :exclude_from_kubernetes
  idempotent!

  def perform
    return if Gitlab::Database.read_only?
    return unless Feature.enabled?(:merge_request_refs_cleanup, default_enabled: false)

    MergeRequestCleanupRefsWorker.perform_with_capacity
  end
end
