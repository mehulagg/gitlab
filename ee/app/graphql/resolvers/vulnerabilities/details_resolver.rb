# frozen_string_literal: true

module Resolvers
  module Vulnerabilities
    class DetailsResolver < BaseResolver
      type [::Types::VulnerabilityDetailType], null: false

      def resolve
        return [] if object.finding_details.blank?

        self.class.with_field_name(object.finding_details.with_indifferent_access)
      end

      def self.with_field_name(items)
        return [] if items.blank?

        items.map { |field_name, field| field.merge(field_name: field_name) }
      end
    end
  end
end
