# frozen_string_literal: true

module Elastic
  class Setting < ApplicationRecord
    self.table_name = 'elastic_settings'

    DEFAULT_REPLICAS = 1
    DEFAULT_SHARDS = 5

    validates :number_of_replicas, :number_of_shards, presence: true

    class << self
      def current
        first || create!(
          number_of_replicas: { default: DEFAULT_REPLICAS },
          number_of_shards: { default: DEFAULT_SHARDS }
        )
      end

      def number_of_shards
        current.number_of_shards.with_indifferent_access.tap do |hash|
          hash.default = DEFAULT_SHARDS
        end
      end

      def number_of_replicas
        current.number_of_replicas.with_indifferent_access.tap do |hash|
          hash.default = DEFAULT_REPLICAS
        end
      end
    end
  end
end
