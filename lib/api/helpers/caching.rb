# frozen_string_literal: true

module API
  module Helpers
    module Caching
      def cache
        @cache ||= Rails.cache
      end

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

      def cached_object(object, presenter:, presenter_args:)
        cache.fetch(object) do
          presenter.represent(object, **presenter_args).to_json
        end
      end

      def cached_collection(collection, presenter:, presenter_args:)
        json = fetch_multi(collection) do |obj|
          presenter.represent(obj, **presenter_args).to_json
        end

        json.values
      end

      def fetch_multi(*objs, **kwargs, &block)
        objs.flatten!
        map = multi_key_map(objs)

        cache.fetch_multi(*map.keys, **kwargs) do |key|
          block.call(map[key])
        end
      end

      def multi_key_map(objects)
        objects.reduce(Hash.new) do |hash, obj|
          hash[obj.cache_key] = obj

          hash
        end
      end
    end
  end
end
