# frozen_string_literal: true

module Mutations
  module GitlabSubscriptions
    class Activate < BaseMutation
      graphql_name 'GitlabSubscriptionActivate'

      authorize :manage_subscription

      argument :activation_code, GraphQL::STRING_TYPE,
               required: true,
               description: 'Activation code received after purchasing a GitLab subscription.'

      def resolve(activation_code:)
        authorize! :global

        result = ::GitlabSubscriptions::ActivateService.new.execute(activation_code)

        { errors: Array(result[:errors]) }
      end
    end
  end
end
