# frozen_string_literal: true

module Types
  class AvailabilityEnum < BaseEnum
    graphql_name 'AvailabilityEnum'
    description 'User availability status'

    value 'BUSY', value: :busy
  end
end
