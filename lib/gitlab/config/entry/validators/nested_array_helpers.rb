# frozen_string_literal: true

module Gitlab
  module Config
    module Entry
      module Validators
        # Include this module to validate deeply nested array of values
        #
        # class MyNestedValidator < ActiveModel::EachValidator
        #   include NestedArrayHelpers
        #
        #   def validate_each(record, attribute, value)
        #     max_level = options.fetch(:max_level, 1)
        #
        #     unless validate_array_recursively(value, max_level) { |v| v.is_a?(Integer) }
        #       record.errors.add(attribute, "is invalid")
        #     end
        #   end
        # end
        #
        module NestedArrayHelpers
          def validate_array_recursively(values, level, &validator_proc)
            return true if yield(values)
            return false if level == 0
            return false unless values.is_a?(Array)

            values.all? { |element| validate_array_recursively(element, level - 1, &validator_proc) }
          end
        end
      end
    end
  end
end
