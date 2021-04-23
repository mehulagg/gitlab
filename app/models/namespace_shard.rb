# frozen_string_lteral: true

class NamespaceShard < ApplicationRecord
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    shard_one: { writing: :shard_one, reading: :shard_one }
  }
end
