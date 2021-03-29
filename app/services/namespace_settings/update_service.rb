# frozen_string_literal: true

module NamespaceSettings
  class UpdateService
    include ::Gitlab::Allowable

    attr_reader :current_user, :group, :settings_params

    def initialize(current_user, group, settings)
      @current_user = current_user
      @group = group
      @settings_params = settings
    end

    def execute
      check_admin_resource_access_token_creation_allowed

      if group.namespace_settings
        group.namespace_settings.attributes = settings_params
      else
        group.build_namespace_settings(settings_params)
      end
    end

    private

    def check_admin_resource_access_token_creation_allowed
      return if settings_params[:resource_access_token_creation_allowed].nil?

      unless can?(current_user, :admin_group, group)
        settings_params.delete(:resource_access_token_creation_allowed)
        group.errors.add(:resource_access_token_creation_allowed, _('can only be changed by a group admin.'))
      end
    end
  end
end

NamespaceSettings::UpdateService.prepend_if_ee('EE::NamespaceSettings::UpdateService')
