# frozen_string_literal: true

module Elastic
  module BulkCronWorker
    extend ActiveSupport::Concern

    included do
      include ApplicationWorker
      include Gitlab::ExclusiveLeaseHelpers
      # There is no onward scheduling and this cron handles work from across the
      # application, so there's no useful context to add.
      include CronjobQueue # rubocop:disable Scalability/CronWorkerContext
    end

    def perform
      if Elastic::IndexingControl.non_cached_pause_indexing?
        logger.info(message: "elasticsearch_pause_indexing setting is enabled. #{self.class} execution is skipped.")
        return false
      end

      in_lock(self.class.name.underscore, ttl: 10.minutes, retries: 10, sleep_sec: 1) do
        records_count = service.execute
        log_extra_metadata_on_done(:records_count, records_count)
      end
    rescue Gitlab::ExclusiveLeaseHelpers::FailedToObtainLockError
      # We're scheduled on a cronjob, so nothing to do here
    end

    private

    def logger
      Elastic::IndexingControl.logger
    end
  end
end
