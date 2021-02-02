# frozen_string_literal: true

module Types
  class EventTargetTypeEnum < BaseEnum
    graphql_name 'EventType'
    description 'Event type'

    ::Event.target_types.each do |target_type|
      value target_type.upcase, value: target_type, description: "#{target_type.titleize} event type"
    end
  end
end
