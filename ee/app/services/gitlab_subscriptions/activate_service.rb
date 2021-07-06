# frozen_string_literal: true

# Activating self-managed instances
# Part of Cloud Licensing https://gitlab.com/groups/gitlab-org/-/epics/1735
module GitlabSubscriptions
  class ActivateService
    ERROR_MESSAGES = {
      not_self_managed: 'Not self-managed instance',
    }.freeze

    def execute(activation_code)
      return error(ERROR_MESSAGES[:not_self_managed]) if Gitlab.com?

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

    def find_or_initialize_cloud_license(license_key)
      return License.current.reset if License.current_cloud_license?(license_key)

      License.new(data: license_key, cloud: true)
    end
  end
end
