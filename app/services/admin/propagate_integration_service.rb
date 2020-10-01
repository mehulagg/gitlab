# frozen_string_literal: true

module Admin
  class PropagateIntegrationService
    include PropagateService

    def propagate
      update_inherited_integrations

      if integration.instance?
        create_integration_for_groups_without_integration if Feature.enabled?(:group_level_integrations)
        create_integration_for_projects_without_integration
      else
        create_integration_for_groups_belonging_to_group_without_integration
        create_integration_for_projects_belonging_to_group_without_integration
      end
    end

    private

    # rubocop: disable Cop/InBatches
    def update_inherited_integrations
      Service.by_type(integration.type).inherit_from_id(integration.id).in_batches(of: BATCH_SIZE) do |services|
        min_id, max_id = services.pick("MIN(services.id), MAX(services.id)")
        PropagateIntegrationInheritWorker.perform_async(integration.id, min_id, max_id)
      end
    end
    # rubocop: enable Cop/InBatches

    def create_integration_for_groups_without_integration
      Group.without_integration(integration).each_batch(of: BATCH_SIZE) do |groups|
        min_id, max_id = groups.pick("MIN(namespaces.id), MAX(namespaces.id)")
        PropagateIntegrationGroupWorker.perform_async(integration.id, min_id, max_id)
      end
    end

    def create_integration_for_groups_belonging_to_group_without_integration
      Group.belonging_to_group_without_integration(integration).each_batch(of: BATCH_SIZE) do |groups|
        min_id, max_id = groups.pick("MIN(namespaces.id), MAX(namespaces.id)")
        PropagateIntegrationGroupWorker.perform_async(integration.id, min_id, max_id)
      end
    end

    def create_integration_for_projects_belonging_to_group_without_integration
      Project.belonging_to_group_without_integration(integration).each_batch(of: BATCH_SIZE) do |projects|
        min_id, max_id = projects.pick("MIN(projects.id), MAX(projects.id)")
        PropagateIntegrationProjectWorker.perform_async(integration.id, min_id, max_id)
      end
    end
  end
end
