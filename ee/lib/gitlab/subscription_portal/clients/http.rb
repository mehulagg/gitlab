# frozen_string_literal: true

module Gitlab
  module SubscriptionPortal
    module Clients
      class HTTP < BaseClient
        class << self
          def generate_trial(params)
            http_post("trials", admin_headers, params)
          end

          def create_customer(params)
            http_post("api/customers", admin_headers, params)
          end

          def create_subscription(params, email, token)
            http_post("subscriptions", customer_headers(email, token), params)
          end

          def payment_form_params(payment_type)
            http_get("payment_forms/#{payment_type}", admin_headers)
          end

          def payment_method(id)
            http_get("api/payment_methods/#{id}", admin_headers)
          end
        end
      end
    end
  end
end
