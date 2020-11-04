# frozen_string_literal: true

module Resolvers
  module Ci
    class JobsResolver < BaseResolver
      include LooksAhead

      def resolve_with_lookahead(**args)
        apply_lookahead(object.statuses)
      end

      def preloads
        {
          artifacts: [:job_artifacts]
        }
      end
    end
  end
end

Resolvers::Ci::JobsResolver.prepend_if_ee('::EE::Resolvers::Ci::JobsResolver')
