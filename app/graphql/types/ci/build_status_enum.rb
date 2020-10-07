# frozen_string_literal: true

module Types
  module Ci
    class BuildStatusEnum < BaseEnum
      graphql_name 'CiBuildStatus'

      ::Ci::HasStatus::AVAILABLE_STATUSES.each do |status|
        value status.to_s.upcase,
          description: "A build that is #{status.tr('_', ' ')}",
          value: status
      end
    end
  end
end
