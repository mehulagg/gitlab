# frozen_string_literal: true

module EE
  module Types
    module IssuableType
      extend ActiveSupport::Concern

      prepended do
        possible_types ::Types::EpicType
      end

      class_methods do
        def resolve_type(object, context)
          case object
          when ::Epic
            ::Types::EpicType
          else
            super
          end
        end
      end
    end
  end
end
