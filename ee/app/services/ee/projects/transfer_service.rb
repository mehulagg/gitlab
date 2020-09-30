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

      override :transfer_missing_namespace_resources
      def transfer_missing_namespace_resources
        super

        ::Epic.nullify_lost_issue_links(@old_group.self_and_descendants, lost_issues)
        # Move missing epics
        # Epics::TransferService.new(current_user, @old_group, @new_namespace).execute
      end

      def lost_issues
        ancestors = group.ancestors

        if ancestors.include?(new_parent_group)
          group.ancestors_upto(new_parent_group)
        else
          ancestors
        end
      end
    end
  end
end
