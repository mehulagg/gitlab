# frozen_string_literal: true

module Groups
  class UpdateService < Groups::BaseService
    include UpdateVisibilityLevel

    def execute
      reject_parent_id!
      remove_unallowed_params

      if renaming_group_with_container_registry_images?
        group.errors.add(:base, container_images_error)
        return false
      end

      return false unless valid_visibility_level_change?(group, params[:visibility_level])

      return false unless valid_share_with_group_lock_change?

      return false unless valid_path_change_with_npm_packages?

      return false unless update_shared_runners

      before_assignment_hook(group, params)

      handle_namespace_settings

      group.assign_attributes(params)

      begin
        success = group.save

        after_update if success

        success
      rescue Gitlab::UpdatePathError => e
        group.errors.add(:base, e.message)

        false
      end
    end

    private

    def handle_namespace_settings
      settings_params = params.slice(*::NamespaceSetting::NAMESPACE_SETTINGS_PARAMS)

      return if settings_params.empty?

      ::NamespaceSetting::NAMESPACE_SETTINGS_PARAMS.each do |nsp|
        params.delete(nsp)
      end

      ::NamespaceSettings::UpdateService.new(current_user, group, settings_params).execute
    end

    def valid_path_change_with_npm_packages?
      return true unless group.packages_feature_enabled?
      return true if params[:path].blank?
      return true if !group.has_parent? && group.path == params[:path]

      npm_packages = ::Packages::GroupPackagesFinder.new(current_user, group, package_type: :npm).execute
      if npm_packages.exists?
        group.errors.add(:path, s_('GroupSettings|cannot change when group contains projects with NPM packages'))
        return
      end

      true
    end

    def before_assignment_hook(group, params)
      # overridden in EE
    end

    def renaming_group_with_container_registry_images?
      new_path = params[:path]

      new_path &&
        new_path != group.path &&
        group.has_container_repository_including_subgroups?
    end

    def container_images_error
      s_("GroupSettings|Cannot update the path because there are projects under this group that contain Docker images in their Container Registry. Please remove the images from your projects first and try again.")
    end

    def after_update
      if group.previous_changes.include?(:visibility_level) && group.private?
        # don't enqueue immediately to prevent todos removal in case of a mistake
        TodosDestroyer::GroupPrivateWorker.perform_in(Todo::WAIT_FOR_DELETE, group.id)
      end
    end

    def reject_parent_id!
      params.delete(:parent_id)
    end

    # overridden in EE
    def remove_unallowed_params
      params.delete(:emails_disabled) unless can?(current_user, :set_emails_disabled, group)
      params.delete(:default_branch_protection) unless can?(current_user, :update_default_branch_protection, group)
    end

    def valid_share_with_group_lock_change?
      return true unless changing_share_with_group_lock?
      return true if can?(current_user, :change_share_with_group_lock, group)

      group.errors.add(:share_with_group_lock, s_('GroupSettings|cannot be disabled when the parent group "Share with group lock" is enabled, except by the owner of the parent group'))
      false
    end

    def changing_share_with_group_lock?
      return false if params[:share_with_group_lock].nil?

      params[:share_with_group_lock] != group.share_with_group_lock
    end

    def update_shared_runners
      return true if params[:shared_runners_setting].nil?

      result = Groups::UpdateSharedRunnersService.new(group, current_user, shared_runners_setting: params.delete(:shared_runners_setting)).execute

      return true if result[:status] == :success

      group.errors.add(:update_shared_runners, result[:message])
      false
    end
  end
end

Groups::UpdateService.prepend_if_ee('EE::Groups::UpdateService')
