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
      #   @param presenter_args [Hash] keyword arguments to be passed to the entity
      #   @return [Gitlab::Json::PrecompiledJson]
      #
      # @overload present_cached(tags, with: Entities::Tag, project: tag.project)
      #   @param obj_or_collection [Enumerable<Object>] the objects to render
      #   @param with [Grape::Entity] the entity to use for rendering
      #   @param presenter_args [Hash] keyword arguments to be passed to the entity
      #   @return [Gitlab::Json::PrecompiledJson]
      def present_cached(obj_or_collection, with:, **presenter_args)
        json =
          case
          when obj_or_collection.is_a?(Enumerable)
            cached_collection(obj_or_collection, presenter: with, presenter_args: presenter_args)
          else
            cached_object(obj_or_colletion, presenter: with, presenter_args: presenter_args)
          end

        body Gitlab::Json::PrecompiledJson.new(json)
      end

      private

      # Used for fetching or rendering a single object
      #
      # @param object [Object] the object to render
      # @param presenter [Grape::Entity]
      # @param presenter_args [Hash] keyword arguments to be passed to the entity
      # @return [String]
      def cached_object(object, presenter:, presenter_args:)
        cache.fetch(object) do
          Gitlab::Json.dump(presenter.represent(object, **presenter_args).as_json)
        end
      end

      # Used for fetching or rendering multiple objects
      #
      # @param objects [Enumerable<Object>] the objects to render
      # @param presenter [Grape::Entity]
      # @param presenter_args [Hash] keyword arguments to be passed to the entity
      # @return [Array<String>]
      def cached_collection(collection, presenter:, presenter_args:)
        json = fetch_multi(collection) do |obj|
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
      def fetch_multi(*objs, **kwargs, &block)
        objs.flatten!
        map = multi_key_map(objs)

        cache.fetch_multi(*map.keys, **kwargs) do |key|
          block.call(map[key])
        end
      end

      # @param objects [Enumerable<Object>] objects which _must_ respond to `#cache_key`
      # @return [Hash]
      def multi_key_map(objects)
        objects.reduce(Hash.new) do |hash, obj|
          hash[obj.cache_key] = obj

          hash
        end
      end
    end
  end
end
