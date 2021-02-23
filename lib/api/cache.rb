# frozen_string_literal: true

module API
  class Cache
    class Repository
      def initialize(repository:)
        @repository = repository
      end

      def cache
        @cache ||= Rails.cache
      end

      def multi_fetch(key, objects, cache_key_method: :cache_key)
        obj_map = mapped_by_cache_key(objects, cache_key_method: cache_key_method)

        cache.fetch_and_add_missing(key, ) do |missing_keys, hash|
          missing_tags.each do |tag|
            hash[tag.name] = Entities::Tag.represent(tag, project: user_project)
          end
        end
      end

      private

      def mapped_by_cache_key(objects, cache_key_method:)
        objects.reduce(Hash.new) do |obj, hash|
          hash[obj.send(cache_key_method)] = obj
        end
      end
    end
  end
end
