# frozen_string_literal: true

module Security
  module ApiFuzzing
    class ScanProfile
      attr_reader :name, :description, :yaml

      def initialize(name:, description:, yaml:)
        @name = name
        @description = description
        @yaml = yaml
      end
    end
  end
end
