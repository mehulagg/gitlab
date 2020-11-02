# frozen_string_literal: true

module EE
  module Projects
    module UpdateService
      extend ::Gitlab::Utils::Override
      include CleanupApprovers

      PULL_MIRROR_ATTRIBUTES = %i[
        mirror
        mirror_user_id
        import_url
        username_only_import_url
        mirror_trigger_builds
        only_mirror_protected_branches
        mirror_overwrites_diverged_branches
        pull_mirror_branch_prefix
        import_data_attributes
      ].freeze

      override :execute
      def execute
        should_remove_old_approvers = params.delete(:remove_old_approvers)
        limit = params.delete(:repository_size_limit)
        wiki_was_enabled = project.wiki_enabled?

        mirror_user_setting
        compliance_framework_setting
        return update_failed! if project.errors.any?

        result = super do
          # Repository size limit comes as MB from the view
          project.repository_size_limit = ::Gitlab::Utils.try_megabytes_to_bytes(limit) if limit
        end

        if result[:status] == :success
          cleanup_approvers(project) if should_remove_old_approvers
          refresh_merge_trains(project)

          log_audit_events

          sync_wiki_on_enable if !wiki_was_enabled && project.wiki_enabled?
          project.import_state.force_import_job! if params[:mirror].present? && project.mirror?
          project.remove_import_data if project.previous_changes.include?('mirror') && !project.mirror?
        end

        result
      end

      private

      # A user who changes any aspect of pull mirroring settings must be made
      # into the mirror user, to prevent them from acquiring capabilities
      # owned by the previous user, such as writing to a protected branch.
      #
      # Only admins can set the mirror user to be an arbitrary user.
      def mirror_user_setting
        return unless PULL_MIRROR_ATTRIBUTES.any? { |symbol| params.key?(symbol) }

        if params[:mirror_user_id] && params[:mirror_user_id] != project.mirror_user_id
          project.errors.add(:mirror_user_id, 'is invalid') unless current_user&.admin?
        else
          params[:mirror_user_id] = current_user.id
        end
      end

      def compliance_framework_setting
        settings = params[:compliance_framework_setting_attributes]
        return unless settings.present?

        unless can?(current_user, :admin_compliance_framework, project)
          params.delete(:compliance_framework_setting_attributes)
          return
        end

        settings.merge!(_destroy: settings[:framework].blank?)
      end

      def log_audit_events
        EE::Audit::ProjectChangesAuditor.new(current_user, project).execute
      end

      def sync_wiki_on_enable
        ::Geo::RepositoryUpdatedService.new(project.wiki.repository).execute
      end

      def refresh_merge_trains(project)
        return unless project.merge_pipelines_were_disabled?

        MergeTrain.first_in_trains(project).each do |merge_request|
          AutoMergeProcessWorker.perform_async(merge_request.id)
        end
      end
    end
  end
end
