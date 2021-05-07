# frozen_string_literal: true

module GitlabSubscriptions
  class FilterPurchaseEligibleNamespacesService
    include ::Gitlab::Utils::StrongMemoize

    def initialize(user:, namespaces:)
      @user = user
      @namespaces = namespaces
    end

    def execute
      return success([]) if namespaces.empty?
      return missing_user_error if user.nil?

      if response[:success]
        eligible_ids = response[:data].map { |data| data['id'] }.to_set

        data = namespaces.filter { |namespace| eligible_ids.include?(namespace.id) }

        success(data)
      else
        error('Failed to fetch namespaces', response.dig(:data, :errors))
      end
    end

    private

    attr_reader :user, :namespaces

    def success(payload)
      ServiceResponse.success(payload: payload)
    end

    def error(message, payload = nil)
      ServiceResponse.error(message: message, payload: payload)
    end

    def missing_user_error
      message = 'User cannot be nil'
      Gitlab::ErrorTracking.track_and_raise_for_dev_exception(ArgumentError.new(message))

      error(message)
    end

    def response
      strong_memoize(:response) do
        Gitlab::SubscriptionPortal::Client.filter_purchase_eligible_namespaces(user, namespaces)
      end
    end
  end
end
