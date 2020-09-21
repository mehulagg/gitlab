# frozen_string_literal: true

class PropagateIntegrationProjectWorker
  include ApplicationWorker

  feature_category :integrations
  idempotent!
  loggable_arguments 1

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(integration_id, min_id, max_id)
    integration = Service.find_by_id(integration_id)
    return unless integration

    batch_ids = Project.where(id: min_id..max_id).without_integration(integration).pluck(:id)

    BulkCreateIntegrationService.new(integration, batch_ids, 'project').execute
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
