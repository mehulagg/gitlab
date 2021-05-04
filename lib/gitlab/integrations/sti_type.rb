# frozen_string_literal: true

module Gitlab
  module Integrations
    class StiType < ActiveRecord::Type::String
      NAMESPACED_INTEGRATIONS = Set.new(%w(
        Asana Assembla Bamboo
      )).freeze

      def cast(value)
        new_cast(value) || super
      end

      def serialize(value)
        new_serialize(value) || super
      end

      def deserialize(value)
        value
      end

      def changed?(original_value, value, _new_value_before_type_cast)
        original_value != serialize(value)
      end

      def changed_in_place?(original_value_for_database, value)
        original_value_for_database != serialize(value)
      end

      private

      def new_cast(value)
        return unless value

        stripped_name = value.remove(/Service\Z/)
        return unless NAMESPACED_INTEGRATIONS.include?(stripped_name)

        "Integrations::#{stripped_name}"
      end

      def new_serialize(value)
        return unless value.starts_with?('Integrations::')

        "#{value.remove('Integrations::')}Service"
      end
    end
  end
end
