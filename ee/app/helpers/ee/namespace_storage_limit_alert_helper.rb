# frozen_string_literal: true

module EE
  module NamespaceStorageLimitAlertHelper
    extend ::Gitlab::Utils::Override

    override :display_namespace_storage_limit_alert!
    def display_namespace_storage_limit_alert!
      @display_namespace_storage_limit_alert = true
    end

    def display_namespace_storage_limit_alert?
      @display_namespace_storage_limit_alert
    end

    def namespace_storage_alert(namespace)
      return {} if current_user.nil?

      payload = Namespaces::CheckStorageSizeService.new(namespace, current_user).execute.payload

      return {} if payload.empty?

      alert_level = payload[:alert_level]
      root_namespace = payload[:root_namespace]

      return {} if cookies["hide_storage_limit_alert_#{root_namespace.id}_#{alert_level}"] == 'true'

      payload
    end

    def namespace_storage_alert_style(alert_level)
      if alert_level == :error || alert_level == :alert
        'danger'
      else
        alert_level.to_s
      end
    end

    def namespace_storage_alert_icon(alert_level)
      if alert_level == :error || alert_level == :alert
        'error'
      elsif alert_level == :info
        'information-o'
      else
        alert_level.to_s
      end
    end

    def namespace_storage_usage_link(namespace)
      if namespace.group?
        group_usage_quotas_path(namespace, anchor: 'storage-quota-tab')
      else
        profile_usage_quotas_path(anchor: 'storage-quota-tab')
      end
    end

    def purchase_storage_url
      return unless ::Gitlab.dev_env_or_com?
      return unless ::Gitlab::CurrentSettings.enforce_namespace_storage_limit?
      return unless ::Feature.enabled?(:buy_storage_link)

      EE::SUBSCRIPTIONS_MORE_STORAGE_URL
    end
  end
end
