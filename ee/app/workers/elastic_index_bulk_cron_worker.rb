# frozen_string_literal: true

class ElasticIndexBulkCronWorker # rubocop:disable Scalability/IdempotentWorker
  include Elastic::BulkCronWorker

  feature_category :global_search
  urgency :throttled
  # Even though this worker is idempotent, until https://gitlab.com/gitlab-org/gitlab/-/issues/325291 is done
  # we can't use it with read-only database replicas
  data_consistency :delayed, feature_flag: :load_balancing_for_bulk_cron_workers

  private

  def service
    Elastic::ProcessBookkeepingService.new
  end
end
