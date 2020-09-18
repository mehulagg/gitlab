# frozen_string_literal: true

class PropagateIntegrationInheritWorker
  include ApplicationWorker

  feature_category :integrations
  idempotent!
  loggable_arguments 1

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(integration_id, min_id, max_id)
    integration = Service.find(integration_id)
    services = Service.where(id: min_id..max_id).by_type(integration.type).inherit_from_id(integration.id)

    BulkUpdateIntegrationService.new(integration, services).execute
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
