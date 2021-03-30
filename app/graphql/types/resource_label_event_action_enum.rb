# frozen_string_literal: true

module Types
  class ResourceLabelEventActionEnum < BaseEnum
    graphql_name 'LabelEventAction'
    description 'Action of a label event.'

    ResourceLabelEvent.actions.each_key do |name|
      value name.upcase,
            value: name,
            description: "An event to #{name} the label."
    end
  end
end
