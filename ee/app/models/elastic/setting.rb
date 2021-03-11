# frozen_string_literal: true

module Elastic
  class Setting < ApplicationRecord
    self.table_name = 'elastic_settings'

    validates :number_of_replicas, :number_of_shards, presence: true

    def self.current
      first || create!(
        number_of_replicas: { default: 1 },
        number_of_shards: { default: 5 }
      )
    end
  end
end
