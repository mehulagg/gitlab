# frozen_string_literal: true

module Mutations
  module Vulnerabilities
    class RevertToDetected < BaseMutation
      graphql_name 'RevertVulnerabilityToDetected'

      authorize :admin_vulnerability

      field :vulnerability, Types::VulnerabilityType,
            null: true,
            description: 'The vulnerability after revert'

      argument :id,
               GraphQL::ID_TYPE,
               required: true,
               description: 'ID of the vulnerability to be reverted'

      def resolve(id:)
        vulnerability = authorized_find!(id: id)
        result = revert_vulnerability_to_detected(vulnerability)

        {
          vulnerability: result,
          errors: result.errors.full_messages || []
        }
      end

      private

      def revert_vulnerability_to_detected(vulnerability)
        ::Vulnerabilities::RevertToDetectedService.new(current_user, vulnerability).execute
      end

      def find_object(id:)
        GitlabSchema.object_from_id(id)
      end
    end
  end
end
