# frozen_string_literal: true

module EE
  module Resolvers
    module IssuesResolver
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      prepended do
        argument :iteration_id, ::GraphQL::ID_TYPE.to_list_type,
                 required: false,
                 description: 'Iterations applied to the issue.'

        argument :epic_id, GraphQL::STRING_TYPE,
                 required: false,
                 description: 'ID of an epic associated with the issues, "none" and "any" values are supported.'
      end

      private

      override :preloads
      def preloads
        super.merge(
          {
            sla_due_at: [:issuable_sla],
            metric_images: [:metric_images]
          }
        )
      end
    end
  end
end
