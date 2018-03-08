module EE
  module Projects
    module UpdateService
      extend ::Gitlab::Utils::Override

      include CleanupApprovers

      override :execute
      def execute
        unless project.feature_available?(:repository_mirrors)
          params.delete(:mirror)
          params.delete(:mirror_user_id)
          params.delete(:mirror_trigger_builds)
        end

        should_remove_old_approvers = params.delete(:remove_old_approvers)

        result = super

        cleanup_approvers(project) if should_remove_old_approvers && result[:status] == :success

        log_audit_events if result[:status] == :success

        result
      end

      def changing_storage_size?
        new_repository_storage = params[:repository_storage]

        new_repository_storage && project.repository.exists? &&
          can?(current_user, :change_repository_storage, project)
      end

      private

      def log_audit_events
        EE::Audit::ProjectChangesAuditor.new(current_user, project).execute
      end
    end
  end
end
