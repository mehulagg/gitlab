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
      if group.namespace_settings
        group.namespace_settings.attributes = settings_params
      else
        group.build_namespace_settings(settings_params)
      end

      after_update
    end

    def after_update
      settings = group.namespace_settings
      return if settings.allow_mfa_for_subgroups

      if settings.previous_changes.include?(:allow_mfa_for_subgroups)
        # enque in batches
        TodosDestroyer::GroupPrivateWorker.perform_in(Todo::WAIT_FOR_DELETE, group.id)
      end
    end
  end
end

NamespaceSettings::UpdateService.prepend_if_ee('EE::NamespaceSettings::UpdateService')
