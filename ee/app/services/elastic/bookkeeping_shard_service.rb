# frozen_string_literal: true

module Elastic
  class BookkeepingShardService
    def self.shard_number(number_of_shards:, data:)
      Digest::SHA256.hexdigest(data).hex % number_of_shards
    end
  end
end
