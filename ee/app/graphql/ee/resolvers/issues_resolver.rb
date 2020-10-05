# frozen_string_literal: true

module EE
  module Resolvers
    module IssuesResolver
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      prepended do
        argument :iteration_id, ::GraphQL::ID_TYPE.to_list_type,
                 required: false,
                 description: 'Iterations applied to the issue'
      end

      private

      override :preloads
      def preloads
        super.merge(
          {
            sla_due_at: [:incident_sla]
          }
        )
      end
    end
  end
end
