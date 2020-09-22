# frozen_string_literal: true

module Gitlab
  module Database
    class PostgresIndex < ApplicationRecord
      self.table_name = 'postgres_indexes'
      self.primary_key = 'identifier'

      alias_attribute :unique?, :is_unique
      alias_attribute :valid?, :is_valid

      scope :by_identifier, ->(identifier) do
        raise ArgumentError, "Index name is not fully qualified with a schema: #{identifier}" unless identifier =~ /^\w+\.\w+$/

        find(identifier)
      end

      scope :regular, -> { where(is_unique: false).where("NOT schema ~* '^gitlab_partitions_'") }

      scope :random_few, ->(how_many = 2) do
        limit(how_many).order(Arel.sql('RANDOM()'))
      end

      def to_s
        name
      end
    end
  end
end
