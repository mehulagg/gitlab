# frozen_string_literal: true

module Gitlab
  module Utils
    class Caching
      class << self
        # An adapted version of ActiveSupport::Cache::Store#fetch_multi.
        #
        # The original method only provides the missing key to the block,
        # not the missing object, so we have to create a map of cache keys
        # to the objects to allow us to pass the object to the missing value
        # block.
        #
        # The result is that this is functionally identical to `#fetch`.
        def fetch_multi(*objs, context: nil, **kwargs)
          objs.flatten!
          map = multi_key_map(objs, context: context)

          Rails.cache.fetch_multi(*map.keys, **kwargs) do |key|
            yield map[key]
          end
        end

        private

        # Optionally uses a `Proc` to add context to a cache key
        #
        # @param object [Object] must respond to #cache_key
        # @param context [Proc] a proc that will be called with the object as an argument, and which should return a
        #                       string or array of strings to be combined into the cache key
        # @return [String]
        def contextual_cache_key(object, context)
          return object.cache_key if context.nil?

          [object.cache_key, context.call(object)].flatten.join(":")
        end

        # @param objects [Enumerable<Object>] objects which _must_ respond to `#cache_key`
        # @param context [Proc] a proc that can be called to help generate each cache key
        # @return [Hash]
        def multi_key_map(objects, context:)
          objects.index_by do |object|
            contextual_cache_key(object, context)
          end
        end
      end
    end
  end
end
