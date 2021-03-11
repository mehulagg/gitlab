# frozen_string_literal: true

module Elastic
  class Setting < ApplicationRecord
    self.table_name = 'advanced_search_settings'

    serialize :number_of_replicas, :number_of_shards, Serializers::JSON # rubocop:disable Cop/ActiveRecordSerialize
  end
end
