# frozen_string_literal: true

module Mutations
  module Vulnerabilities
    class Dismiss < BaseMutation
      graphql_name 'VulnerabilityDismiss'

      authorize :admin_vulnerability

      field :vulnerability, Types::VulnerabilityType,
            null: true,
            description: 'The vulnerability after dismissal'

      argument :id,
               GraphQL::ID_TYPE,
               required: true,
               description: 'ID of the vulnerability to be dismissed'

      argument :comment,
               GraphQL::STRING_TYPE,
               required: false,
               description: 'Reason why vulnerability should be dismissed'

      def resolve(id:, comment: nil)
        vulnerability = authorized_find!(id: id)
        result = dismiss_vulnerability(vulnerability, comment)

        {
          vulnerability: result,
          errors: result.errors.full_messages || []
        }
      end

      private

      def dismiss_vulnerability(vulnerability, comment)
        ::Vulnerabilities::DismissService.new(current_user, vulnerability, comment).execute
      end

      def find_object(id:)
        GitlabSchema.object_from_id(id, expected_type: ::Vulnerability)
      end
    end
  end
end
