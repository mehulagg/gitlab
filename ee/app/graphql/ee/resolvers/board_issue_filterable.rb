# frozen_string_literal: true

module EE
  module Resolvers
    module BoardIssueFilterable
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      override :set_filter_values
      def set_filter_values(filters)
        epic_id = filters.delete(:epic_id)
        epic_wildcard_id = filters.delete(:epic_wildcard_id)

        if epic_id && epic_wildcard_id
          raise ::Gitlab::Graphql::Errors::ArgumentError, 'Incompatible arguments: epicId, epicWildcardId.'
        end

        if epic_id
          filters[:epic_id] = ::GitlabSchema.parse_gid(epic_id, expected_type: ::Epic).model_id
        elsif epic_wildcard_id
          filters[:epic_id] = epic_wildcard_id
        end
      end
    end
  end
end
