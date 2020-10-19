# frozen_string_literal: true

class PropagateIntegrationDescendantWorker
  include ApplicationWorker

  feature_category :integrations
  idempotent!

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(integration_id, min_id, max_id)
    integration = Service.find_by_id(integration_id)
    return unless integration

    services = Service.where(id: min_id..max_id).descendant_integrations_for(integration)

    BulkUpdateIntegrationService.new(integration, services).execute
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
