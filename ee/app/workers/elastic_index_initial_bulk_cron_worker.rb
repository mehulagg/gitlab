# frozen_string_literal: true

class ElasticIndexInitialBulkCronWorker
  include Elastic::BulkCronWorker

  feature_category :global_search
  idempotent!
  urgency :throttled

  private

  def service
    Elastic::ProcessInitialBookkeepingService.new
  end
end
