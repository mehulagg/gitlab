# frozen_string_literal: true

module GitlabSubscriptions
  class ReactivateTrialService
    def execute(reactivate_trial_params)
      response = client.reactivate_trial(reactivate_trial_params)

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
