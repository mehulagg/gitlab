# frozen_string_literal: true

module Gitlab
  module SubscriptionPortal
    module Clients
      module REST
        extend ActiveSupport::Concern

        class_methods do
          def generate_trial(params)
            http_post("trials", admin_headers, params)
          end

          def extend_reactivate_trial(params)
            http_put("trials/extend_reactivate_trial", admin_headers, params)
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

          private

          def base_url
            EE::SUBSCRIPTIONS_URL
          end

          def http_get(path, headers)
            response = Gitlab::HTTP.get("#{base_url}/#{path}", headers: headers)

            parse_response(response)
          rescue *Gitlab::HTTP::HTTP_ERRORS => e
            { success: false, data: { errors: e.message } }
          end

          def http_post(path, headers, params = {})
            response = Gitlab::HTTP.post("#{base_url}/#{path}", body: params.to_json, headers: headers)

            parse_response(response)
          rescue *Gitlab::HTTP::HTTP_ERRORS => e
            { success: false, data: { errors: e.message } }
          end

          def http_put(path, headers, params = {})
            response = Gitlab::HTTP.put("#{base_url}/#{path}", body: params.to_json, headers: headers)

            parse_response(response)
          rescue *Gitlab::HTTP::HTTP_ERRORS => e
            { success: false, data: { errors: e.message } }
          end
        end
      end
    end
  end
end
