# frozen_string_literal: true

module EE
  module Types
    module Notes
      module NoteableInterface
        module ClassMethods
          def resolve_type(object, *)
            return ::Types::VulnerabilityType if ::Vulnerability === object

            super
          end
        end

        def self.prepended(base)
          base.singleton_class.prepend(ClassMethods)
        end
      end
    end
  end
end
