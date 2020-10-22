# frozen_string_literal: true

module Gitlab
  module Database
    class PostgresPartitionedTable < ActiveRecord::Base
      DYNAMIC_PARTITION_STRATEGIES = %w[range list].freeze

      self.primary_key = :identifier

      scope :by_identifier, ->(identifier) do
        raise ArgumentError, "Table name is not fully qualified with a schema: #{identifier}" unless identifier =~ /^\w+\.\w+$/

        find(identifier)
      end

      def dynamic?
        DYNAMIC_PARTITION_STRATEGIES.include?(strategy)
      end

      def static?
        !dynamic?
      end

      def to_s
        name
      end
    end
  end
end
