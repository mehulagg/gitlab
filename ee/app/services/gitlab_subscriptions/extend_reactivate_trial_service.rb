# frozen_string_literal: true

module GitlabSubscriptions
  class ExtendReactivateTrialService
    def execute(extend_reactivate_trial_params)
      response = client.extend_reactivate_trial(extend_reactivate_trial_params)

      if response[:success]
        ServiceResponse.success
      else
        ServiceResponse.error(message: response.dig(:data, :errors))
      end
    end

    private

    def client
      Gitlab::SubscriptionPortal::Client
    end
  end
end
