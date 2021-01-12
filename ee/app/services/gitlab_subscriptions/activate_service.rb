# frozen_string_literal: true

# Activating self-managed instances
module GitlabSubscriptions
  class ActivateService
    def execute(activation_code)
      response = client.activate(activation_code)

      if response[:success]
        Gitlab::CurrentSettings.current_application_settings.update!(cloud_license_auth_token: response[:authentication_token])
      end

      response
    end

    private

    def client
      Gitlab::SubscriptionPortal::Client
    end
  end
end
