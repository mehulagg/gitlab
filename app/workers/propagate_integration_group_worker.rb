# frozen_string_literal: true

class PropagateIntegrationGroupWorker
  include ApplicationWorker

  feature_category :integrations
  idempotent!
  loggable_arguments 1

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(integration_id, min_id, max_id)
    integration = Service.find(integration_id)
    batch_ids = Group.where(id: min_id..max_id).without_integration(integration).pluck(:id)

    BulkCreateIntegrationService.new(integration, batch_ids, 'group').execute
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
