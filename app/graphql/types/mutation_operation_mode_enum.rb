# frozen_string_literal: true

module Types
  class MutationOperationModeEnum < BaseEnum
    graphql_name 'MutationOperationMode'
    description 'Different toggles for changing mutator behavior'

    # Suggested param name for the enum: `operation_mode`

    value 'REPLACE', 'Performs a replace operation.'
    value 'APPEND', 'Performs an append operation.'
    value 'REMOVE', 'Performs a removal operation.'

    def self.default_mode
      enum[:replace]
    end

    def self.transform_modes
      enum.values_at(:remove, :append)
    end

    def self.transform_list(mode, current_values, new_values)
      case mode
      when 'REPLACE' then new_values
      when 'APPEND' then current_values | new_values
      when 'REMOVE' then current_values - new_values
      end
    end
  end
end
