# frozen_string_literal: true

class PartitionCreationWorker
  include ApplicationWorker

  sidekiq_options retry: 3
  include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

  feature_category :database
  idempotent!

  def perform
    # Removed in favor of Database::PartitionManagementWorker
  end
end
