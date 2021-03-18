# frozen_string_literal: true

module Mutations
  module GitlabSubscriptions
    class Create < BaseMutation
      graphql_name 'GitlabSubscriptionCreate'

      authorize :manage_subscription

      argument :namespace_id, ::Types::GlobalIDType[::Namespace],
               required: true,
               description: 'Namespace ID to purchase an subscription or an addon for.'

      argument :customer, GraphQL::STRING_TYPE,
               required: true,
               description: 'Customer data for passing to CustomersDot in JSON format.'

      argument :subscription, GraphQL::STRING_TYPE,
               required: true,
               description: 'Subscription data for passing to CustomersDot in JSON format.'

      def resolve(**args)
        authorize! :global

        unless Feature.enabled?(:billings_purchase_subscription)
          raise Gitlab::Graphql::Errors::ResourceNotAvailable, 'billings_purchase_subscription feature is disabled'
        end

        namespace = args[:namespace_id].find

        service = Subscriptions::CreateService.new(
          current_user,
          group: namespace,
          customer_params: customer_params(args[:customer]),
          subscription_params: subscription_params(args[:subscription]))

        result = service.execute

        { success: result[:success], errors: Array(result[:errors]) }
      end

      private

      def customer_params(customer)
        Gitlab::Json.parse(customer).with_indifferent_access
      rescue JSON::ParserError
        raise Gitlab::Graphql::Errors::ArgumentError, 'invalid value for customer'
      end

      def subscription_params(subscription)
        Gitlab::Json.parse(subscription).with_indifferent_access
      rescue JSON::ParserError
        raise Gitlab::Graphql::Errors::ArgumentError, 'invalid value for subscription'
      end
    end
  end
end
