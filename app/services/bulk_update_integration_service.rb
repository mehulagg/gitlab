# frozen_string_literal: true

class BulkUpdateIntegrationService
  def initialize(integration, batch)
    @integration = integration
    @batch = batch
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def execute
    # Retrieving the IDs instantiates the ActiveRecord relation (batch)
    # into concrete models, otherwise update_all will clear the relation.
    # https://stackoverflow.com/q/34811646/462015
    batch_ids = batch.pluck(:id)

    Service.transaction do
      batch.update_all(service_hash)

      if integration.data_fields_present?
        integration.data_fields.class.where(service_id: batch_ids).update_all(data_fields_hash)
      end
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord

  private

  attr_reader :integration, :batch

  def service_hash
    integration.to_service_hash.tap { |json| json['inherit_from_id'] = integration.id }
  end

  def data_fields_hash
    integration.to_data_fields_hash
  end
end
