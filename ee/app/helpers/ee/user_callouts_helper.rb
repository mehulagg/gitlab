# frozen_string_literal: true

module EE
  module UserCalloutsHelper
    extend ::Gitlab::Utils::Override

    GEO_ENABLE_HASHED_STORAGE = 'geo_enable_hashed_storage'
    GEO_MIGRATE_HASHED_STORAGE = 'geo_migrate_hashed_storage'
    CANARY_DEPLOYMENT = 'canary_deployment'
    GOLD_TRIAL = 'gold_trial'
    GOLD_TRIAL_BILLINGS = 'gold_trial_billings'
    THREAT_MONITORING_INFO = 'threat_monitoring_info'
    ACCOUNT_RECOVERY_REGULAR_CHECK = 'account_recovery_regular_check'

    def show_canary_deployment_callout?(project)
      !user_dismissed?(CANARY_DEPLOYMENT) &&
        show_promotions? &&
        # use :canary_deployments if we create a feature flag for it in the future
        !project.feature_available?(:deploy_board)
    end

    def render_enable_hashed_storage_warning
      return unless show_enable_hashed_storage_warning?

      message = enable_hashed_storage_warning_message

      render_flash_user_callout(:warning, message, GEO_ENABLE_HASHED_STORAGE)
    end

    def render_migrate_hashed_storage_warning
      return unless show_migrate_hashed_storage_warning?

      message = migrate_hashed_storage_warning_message

      render_flash_user_callout(:warning, message, GEO_MIGRATE_HASHED_STORAGE)
    end

    def show_enable_hashed_storage_warning?
      return if hashed_storage_enabled?

      !user_dismissed?(GEO_ENABLE_HASHED_STORAGE)
    end

    def show_migrate_hashed_storage_warning?
      return unless hashed_storage_enabled?
      return if user_dismissed?(GEO_MIGRATE_HASHED_STORAGE)

      any_project_not_in_hashed_storage?
    end

    override :render_dashboard_gold_trial
    def render_dashboard_gold_trial(user)
      return unless show_gold_trial?(user, GOLD_TRIAL) &&
          user_default_dashboard?(user) &&
          has_no_trial_or_gold_plan?(user) &&
          has_some_namespaces_with_no_trials?(user)

      render 'shared/gold_trial_callout_content'
    end

    def render_account_recovery_regular_check
      return unless ::Gitlab.com? &&
          current_user &&
          3.months.ago > current_user.created_at &&
          !user_dismissed?(ACCOUNT_RECOVERY_REGULAR_CHECK)

      render 'shared/check_recovery_settings'
    end

    def render_billings_gold_trial(user, namespace)
      return if namespace.gold_plan?
      return unless namespace.never_had_trial?
      return unless show_gold_trial?(user, GOLD_TRIAL_BILLINGS)

      render 'shared/gold_trial_callout_content', is_dismissable: !namespace.free_plan?, callout: GOLD_TRIAL_BILLINGS
    end

    def show_threat_monitoring_info?
      !user_dismissed?(THREAT_MONITORING_INFO)
    end

    private

    def hashed_storage_enabled?
      ::Gitlab::CurrentSettings.current_application_settings.hashed_storage_enabled
    end

    def any_project_not_in_hashed_storage?
      ::Project.with_unmigrated_storage.exists?
    end

    def enable_hashed_storage_warning_message
      message = _('Please enable and migrate to hashed storage to avoid security issues and ensure data integrity. %{migrate_link}')

      add_migrate_to_hashed_storage_link(message)
    end

    def migrate_hashed_storage_warning_message
      message = _('Please migrate all existing projects to hashed storage to avoid security issues and ensure data integrity. %{migrate_link}')

      add_migrate_to_hashed_storage_link(message)
    end

    def add_migrate_to_hashed_storage_link(message)
      migrate_link = link_to(_('For more info, read the documentation.'), help_page_path('administration/repository_storage_types.md', anchor: 'how-to-migrate-to-hashed-storage'), target: '_blank')
      linked_message = message % { migrate_link: migrate_link }
      linked_message.html_safe
    end

    def show_gold_trial?(user, callout = GOLD_TRIAL)
      return false unless user
      return false unless show_gold_trial_suitable_env?
      return false if user_dismissed?(callout)

      true
    end

    def show_gold_trial_suitable_env?
      ::Gitlab.com? && !::Gitlab::Database.read_only?
    end

    def has_no_trial_or_gold_plan?(user)
      return false if user.any_namespace_with_gold?

      !user.any_namespace_with_trial?
    end

    def has_some_namespaces_with_no_trials?(user)
      user&.any_namespace_without_trial?
    end
  end
end
