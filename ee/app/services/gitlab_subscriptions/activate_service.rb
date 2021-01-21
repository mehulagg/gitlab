# frozen_string_literal: true

# Activating self-managed instances
# Part of Cloud Licensing https://gitlab.com/groups/gitlab-org/-/epics/1735
module GitlabSubscriptions
  class ActivateService
    ERROR_MESSAGES = {
      not_self_managed: 'Not self-managed instance',
      disabled: 'Cloud license is disabled'
    }.freeze

    def execute(activation_code)
      return error(ERROR_MESSAGES[:not_self_managed]) if Gitlab.com?
      return error(ERROR_MESSAGES[:disabled]) unless application_settings.cloud_license_enabled?

      response = client.activate(activation_code)

      return response unless response[:success]

      if application_settings.update(cloud_license_auth_token: response[:authentication_token])
        response
      else
        error(application_settings.errors.full_messages)
      end
    rescue => e
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
  end
end
