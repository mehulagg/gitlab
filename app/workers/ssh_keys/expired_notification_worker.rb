# frozen_string_literal: true

module PersonalAccessTokens
  class ExpiredNotificationWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include CronjobQueue

    feature_category :compliance_management

    def perform(*args)
    end
  end
end
