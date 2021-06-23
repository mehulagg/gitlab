# frozen_string_literal: true

module CustomersDot
  class ProxyController < ApplicationController
    skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token

    feature_category :purchase

    CUSTOMERS_GRAPHQL_URL = "#{Gitlab::SubscriptionPortal::SUBSCRIPTIONS_URL}/graphql"

    def graphql
      response = Gitlab::HTTP.post(CUSTOMERS_GRAPHQL_URL,
        body: forward_body.to_json,
        headers: forward_headers
      )

      render json: response.body, status: response.code
    end

    private

    def forward_body
      return params_for_proxy unless current_user

      params_for_proxy.merge(gitlab_user_id: current_user.id)
    end

    def forward_headers
      return base_headers unless current_user

      base_headers.merge(admin_headers)
    end

    def params_for_proxy
      params.require(:proxy).permit(:query, :variables)
    end

    def base_headers
      { 'Content-Type' => 'application/json' }
    end

    def admin_headers
      {
        'X-Admin-Email' => EE::SUBSCRIPTION_PORTAL_ADMIN_EMAIL,
        'X-Admin-Token' => EE::SUBSCRIPTION_PORTAL_ADMIN_TOKEN
      }
    end
  end
end
