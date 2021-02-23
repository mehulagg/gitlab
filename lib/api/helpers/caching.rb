# frozen_string_literal: true

# Grape helpers for caching.
#
# This module helps introduce standardised caching into the Grape API
# in a similar manner to the standard Grape DSL.

module API
  module Helpers
    module Caching
      # @return [ActiveSupport::Cache::Store]
      def cache
        @cache ||= Rails.cache
      end

      # This is functionally equivalent to the standard `#present` used in
      # Grape endpoints, but the JSON for the object, or for each object of
      # a collection, will be cached.
      #
      # With a collection all the keys will be fetched in a single call and the
      # Entity rendered for those missing from the cache, which are then written
      # back into it.
      #
      # Both the single object, and all objects inside a collection, must respond
      # to `#cache_key`.
      #
      # To override the Grape formatter we return a custom wrapper in
      # `Gitlab::Json::PrecompiledJson` which tells the `Gitlab::Json::GrapeFormatter`
      # to export the string without conversion.
      #
      # @overload present_cached(tag, with: Entities::Tag, project: tag.project)
      #   @param obj_or_collection [Object] the object to render
      #   @param with [Grape::Entity] the entity to use for rendering
      #   @param cache_context [Proc] a proc to call for the object to provide more context to the cache key
      #   @param presenter_args [Hash] keyword arguments to be passed to the entity
      #   @return [Gitlab::Json::PrecompiledJson]
      #
      # @overload present_cached(tags, with: Entities::Tag, project: tag.project)
      #   @param obj_or_collection [Enumerable<Object>] the objects to render
      #   @param with [Grape::Entity] the entity to use for rendering
      #   @param cache_context [Proc] a proc to call for each object to provide more context to the cache key
      #   @param presenter_args [Hash] keyword arguments to be passed to the entity
      #   @return [Gitlab::Json::PrecompiledJson]
      def present_cached(obj_or_collection, with:, cache_context: nil, **presenter_args)
        json =
          if obj_or_collection.is_a?(Enumerable)
            cached_collection(obj_or_collection, presenter: with, presenter_args: presenter_args, context: cache_context)
          else
            cached_object(obj_or_collection, presenter: with, presenter_args: presenter_args, context: cache_context)
          end

        body Gitlab::Json::PrecompiledJson.new(json)
      end

      private

      def contextual_cache_key(object, context)
        return object.cache_key if context.nil?

        [object.cache_key, context.call(object)].flatten.join(":")
      end

      # Used for fetching or rendering a single object
      #
      # @param object [Object] the object to render
      # @param presenter [Grape::Entity]
      # @param presenter_args [Hash] keyword arguments to be passed to the entity
      # @param context [Proc]
      # @return [String]
      def cached_object(object, presenter:, presenter_args:, context:)
        cache.fetch(contextual_cache_key(object, context)) do
          Gitlab::Json.dump(presenter.represent(object, **presenter_args).as_json)
        end
      end

      # Used for fetching or rendering multiple objects
      #
      # @param objects [Enumerable<Object>] the objects to render
      # @param presenter [Grape::Entity]
      # @param presenter_args [Hash] keyword arguments to be passed to the entity
      # @param context [Proc]
      # @return [Array<String>]
      def cached_collection(collection, presenter:, presenter_args:, context:)
        json = fetch_multi(collection, context: context) do |obj|
          Gitlab::Json.dump(presenter.represent(obj, **presenter_args).as_json)
        end

        json.values
      end

      # An adapted version of ActiveSupport::Cache::Store#fetch_multi.
      #
      # The original method only provides the missing key to the block,
      # not the missing object, so we have to create a map of cache keys
      # to the objects to allow us to pass the object to the missing value
      # block.
      #
      # The result is that this is functionally identical to `#fetch`.
      def fetch_multi(*objs, context:, **kwargs)
        objs.flatten!
        map = multi_key_map(objs, context: context)

        cache.fetch_multi(*map.keys, **kwargs) do |key|
          yield map[key]
        end
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
