# frozen_string_literal: true

class ElasticIndexBulkCronWorker
  include Elastic::BulkCronWorker

  feature_category :global_search
  idempotent!
  urgency :throttled

  private

  def service
    Elastic::ProcessBookkeepingService.new
  end
end
