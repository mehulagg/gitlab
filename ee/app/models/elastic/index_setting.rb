# frozen_string_literal: true

module Elastic
  class IndexSetting < ApplicationRecord
    self.table_name = 'elastic_index_settings'

    validates :alias_name, uniqueness: true, length: { maximum: 255 }
    validates :number_of_replicas, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :number_of_shards, presence: true, numericality: { only_integer: true, greater_than: 0 }

    scope :order_by_name, -> { order(:alias_name) }

    class << self
      def [](alias_name)
        safe_find_or_create_by(alias_name: alias_name)
      end

      def default
        self[Elastic::Latest::Config.index_name]
      end

      def number_of_replicas
        default.number_of_replicas
      end

      def number_of_shards
        default.number_of_shards
      end
    end
  end
end
