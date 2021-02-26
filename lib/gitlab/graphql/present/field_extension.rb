# frozen_string_literal: true

module Gitlab
  module Graphql
    module Present
      class FieldExtension < ::GraphQL::Schema::FieldExtension
        SAFE_CONTEXT_KEYS = %i[current_user].freeze

        def resolve(object:, arguments:, context:)
          object.try(:present, safe_context_values(context))

          yield(object, arguments)
        end

        private

        def safe_context_values(context)
          context.to_h.slice(*SAFE_CONTEXT_KEYS)
        end
      end
    end
  end
end
