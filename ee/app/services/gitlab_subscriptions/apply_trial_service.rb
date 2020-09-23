# frozen_string_literal: true

module GitlabSubscriptions
  class ApplyTrialService
    def execute(apply_trial_params)
      response = client.generate_trial(apply_trial_params)

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
