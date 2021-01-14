# frozen_string_literal: true

module Mutations
  module GitlabSubscriptions
    class Activate < BaseMutation
      graphql_name 'GitlabSubscriptionActivate'

      authorize :manage_subscription

      argument :activation_code, GraphQL::STRING_TYPE,
               required: true,
               description: 'The activation code received after purchasing a Gitlab subscription.'

      def resolve(activation_code:)
        authorize! :global

        result = ::GitlabSubscriptions::ActivateService.new.execute(activation_code)

        { errors: Array(result[:errors]) }
      end
    end
  end
end
