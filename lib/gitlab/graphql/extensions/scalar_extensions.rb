# frozen_string_literal: true

module Gitlab
  module Graphql
    module Extensions
      module ScalarExtensions
        ID_SUBTYPE_LOCK = Mutex.new

        def self.id_subtypes
          unless defined?(@id_subtypes)
            ID_SUBTYPE_LOCK.synchronize { @id_subtypes = Set.new }
          end

          @id_subtypes
        end

        def self.id_subtype?(type_class)
          id_subtypes.any? { |cls| type_class.ancestors.include?(cls) }
        end

        # Allow ID to unify with registered ID subtypes
        def ==(other)
          if name == 'ID' && other.is_a?(self.class) &&
              ::Gitlab::Graphql::Extensions::ScalarExtensions.id_subtype?(other.type_class)
            return true
          end

          super
        end
      end
    end
  end
end

::GraphQL::ScalarType.prepend(::Gitlab::Graphql::Extensions::ScalarExtensions)
