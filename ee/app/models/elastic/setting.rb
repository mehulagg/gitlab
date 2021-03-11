# frozen_string_literal: true

module Elastic
  class Setting < ApplicationRecord
    self.table_name = 'elastic_settings'

    validates :number_of_replicas, :number_of_shards, presence: true

    class << self
      def current
        first || create!(
          number_of_replicas: { default: 1 },
          number_of_shards: { default: 5 }
        )
      end

      def number_of_shards
        current.number_of_shards.with_indifferent_access
      end

      def number_of_replicas
        current.number_of_replicas.with_indifferent_access
      end
    end
  end
end
