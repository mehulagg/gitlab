# frozen_string_literal: true

module GitlabSubscriptions
  class ExtendTrialService
    def execute(extend_trial_params)
      response = client.extend_trial(extend_trial_params)

      if response[:success]
        { success: true }
      else
        { success: false, errors: response.dig(:data, :errors) }
      end
    end

    private

    def client
      Gitlab::SubscriptionPortal::Client
    end
  end
end
