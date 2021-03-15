# frozen_string_literal: true

module GitlabSubscriptions
  class ExtendReactivateTrialService
    def execute(extend_reactivate_trial_params)
      response = client.extend_reactivate_trial(extend_reactivate_trial_params)

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
