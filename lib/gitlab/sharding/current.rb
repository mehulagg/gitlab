module Gitlab
  module Sharding
    class Current
      class << self
        def id_to_shard(id)
          (id >> 10) & ((1<<13) - 1)
        end
      
        # The intention is to eventually lookup from a DB
        def id_to_shard_name(id)
          shard_id = id_to_shard(id.to_i)
          if shard_id > 0
            :"shard_#{shard_id}"
          else
            :primary
          end
        end

        def lookup_shard(namespace)
          if namespace.id == 2
            :shard_one
          else
            :default
          end
        end
      end
    end
  end
end
