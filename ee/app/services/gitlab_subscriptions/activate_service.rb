# frozen_string_literal: true

# Activating self-managed instances
# Part of Cloud Licensing https://gitlab.com/groups/gitlab-org/-/epics/1735
module GitlabSubscriptions
  class ActivateService
    ERROR_MESSAGES = {
      not_self_managed: 'Not self-managed instance',
      disabled: 'Cloud licensing is disabled'
    }.freeze

    def execute(activation_code)
      return error(ERROR_MESSAGES[:not_self_managed]) if Gitlab.com?
      return error(ERROR_MESSAGES[:disabled]) unless application_settings.cloud_license_enabled?

      response = client.activate(activation_code)

      return response unless response[:success]

      license = find_or_initialize_cloud_license(response[:license_key])
      license.last_synced_at = Time.current

      if license.save
        { success: true, license: license }
      else
        error(license.errors.full_messages)
      end
    rescue StandardError => e
      error(e.message)
    end

    private

    def client
      Gitlab::SubscriptionPortal::Client
    end

    def error(message)
      { success: false, errors: Array(message) }
    end

    def application_settings
      Gitlab::CurrentSettings.current_application_settings
    end

    def find_or_initialize_cloud_license(license_key)
      current_license = License.current

      return current_license if current_license&.cloud_license? && current_license&.data == license_key

      License.new(data: license_key, cloud: true)
    end
  end
end
