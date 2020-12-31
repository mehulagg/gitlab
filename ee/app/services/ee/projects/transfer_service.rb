# frozen_string_literal: true

module EE
  module Projects
    module TransferService
      extend ::Gitlab::Utils::Override

      private

      override :execute_system_hooks
      def execute_system_hooks
        super

        EE::Audit::ProjectChangesAuditor.new(current_user, project).execute

        ::Geo::RepositoryRenamedEventStore.new(
          project,
          old_path: project.path,
          old_path_with_namespace: old_path
        ).create!
      end

      override :transfer_missing_group_resources
      def transfer_missing_group_resources(group)
        super

        ::Epics::TransferService.new(current_user, group, project).execute
      end

      override :post_update_hooks
      def post_update_hooks(project)
        # handle when project is moved from a group to a group with different elasticsearch settings
        if old_namespace.use_elasticsearch? != new_namespace.use_elasticsearch?
          ::Gitlab::CurrentSettings.invalidate_elasticsearch_indexes_cache_for_project!(project.id)
          project.maintain_elasticsearch_update(updated_attributes: [:visibility_level]) if project.maintaining_elasticsearch?
        end

        super
      end
    end
  end
end
