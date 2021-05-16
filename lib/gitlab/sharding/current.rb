module Gitlab
  module Sharding
    class Current
      CURRENT_REQUEST_TOP_LEVEL_NAMESPACE_SHARD = :current_request_top_level_namespace_shard
      CURRENT_REQUEST_TOP_LEVEL_NAMESPACE_ID = :current_request_top_level_namespace_id

      class << self
        def set_top_level_namespace!(namespace)
          Gitlab::SafeRequestStore[CURRENT_REQUEST_TOP_LEVEL_NAMESPACE_ID] = namespace.id
          Gitlab::SafeRequestStore[CURRENT_REQUEST_TOP_LEVEL_NAMESPACE_SHARD] = lookup_shard(namespace)
        end

        def lookup_shard(namespace)
          if namespace.id == 2
            :shard_one
          else
            :default
          end
        end

        def top_level_namespace_id
          Gitlab::SafeRequestStore[CURRENT_REQUEST_TOP_LEVEL_NAMESPACE_ID]
        end

        def top_level_namespace_shard
          Gitlab::SafeRequestStore[CURRENT_REQUEST_TOP_LEVEL_NAMESPACE_SHARD]
        end
      end
    end
  end
end
