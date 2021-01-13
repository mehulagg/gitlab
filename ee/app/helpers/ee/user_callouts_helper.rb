# frozen_string_literal: true

module EE
  module UserCalloutsHelper
    extend ::Gitlab::Utils::Override

    ACCOUNT_RECOVERY_REGULAR_CHECK = 'account_recovery_regular_check'
    ACTIVE_USER_COUNT_THRESHOLD    = 'active_user_count_threshold'
    CANARY_DEPLOYMENT              = 'canary_deployment'
    GEO_ENABLE_HASHED_STORAGE      = 'geo_enable_hashed_storage'
    GEO_MIGRATE_HASHED_STORAGE     = 'geo_migrate_hashed_storage'
    GOLD_TRIAL                     = 'gold_trial'
    GOLD_TRIAL_BILLINGS            = 'gold_trial_billings'
    NEW_USER_SIGNUPS_CAP_REACHED   = 'new_user_signups_cap_reached'
    PERSONAL_ACCESS_TOKEN_EXPIRY   = 'personal_access_token_expiry'
    THREAT_MONITORING_INFO         = 'threat_monitoring_info'

    def show_canary_deployment_callout?(project)
      false
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
          !user.owns_paid_namespace? &&
          user.any_namespace_without_trial?

      render 'shared/gold_trial_callout_content'
    end

    def render_account_recovery_regular_check
      return unless current_user &&
          ::Gitlab.com? &&
          3.months.ago > current_user.created_at &&
          !user_dismissed?(ACCOUNT_RECOVERY_REGULAR_CHECK, 3.months.ago)

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

    def show_token_expiry_notification?
      return false unless current_user

      !token_expiration_enforced? &&
        current_user.active? &&
        !user_dismissed?(PERSONAL_ACCESS_TOKEN_EXPIRY, 1.week.ago)
    end

    def show_new_user_signups_cap_reached?
      return false unless ::Feature.enabled?(:admin_new_user_signups_cap, default_enabled: true )
      return false unless current_user&.admin?
      return false if user_dismissed?(NEW_USER_SIGNUPS_CAP_REACHED)

      new_user_signups_cap = ::Gitlab::CurrentSettings.current_application_settings.new_user_signups_cap
      return false if new_user_signups_cap.nil?

      new_user_signups_cap.to_i <= ::User.billable.count
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
      migrate_link = link_to(_('For more info, read the documentation.'), help_page_path('administration/raketasks/storage.md', anchor: 'migrate-to-hashed-storage'), target: '_blank')
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

    def token_expiration_enforced?
      ::PersonalAccessToken.expiration_enforced?
    end

    def current_settings
    end
  end
end
