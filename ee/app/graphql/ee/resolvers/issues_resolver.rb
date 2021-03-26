# frozen_string_literal: true

module EE
  module Resolvers
    module IssuesResolver
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      prepended do
        argument :iteration_id, ::GraphQL::ID_TYPE.to_list_type,
                 required: false,
                 description: 'List of iteration Global IDs applied to the issue.'

        argument :epic_id, GraphQL::STRING_TYPE,
                 required: false,
                 description: 'ID of an epic associated with the issues, "none" and "any" values are supported.'
      end

      override :resolve_with_lookahead
      def resolve_with_lookahead(**args)
        args[:iteration_id] = iteration_ids_from_args(args)

        super
      end

      private

      # Originally accepted a raw model id. Now accept a gid, but allow a raw id
      # for backward compatibility
      def iteration_ids_from_args(args)
        return unless args[:iteration_id].present?

        args[:iteration_id].map do |id|
          begin
            ::GitlabSchema.parse_gid(id, expected_type: ::Iteration).model_id
          rescue ::Gitlab::Graphql::Errors::ArgumentError
            id
          end
        end
      end

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
