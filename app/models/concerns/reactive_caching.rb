# frozen_string_literal: true

# The usage of the ReactiveCaching module is documented here:
# https://docs.gitlab.com/ee/development/utilities.html#reactivecaching
module ReactiveCaching
  extend ActiveSupport::Concern

  InvalidateReactiveCache = Class.new(StandardError)

  included do
    class_attribute :reactive_cache_lease_timeout

    class_attribute :reactive_cache_key
    class_attribute :reactive_cache_lifetime
    class_attribute :reactive_cache_refresh_interval
    class_attribute :reactive_cache_worker_finder
    class_attribute :reactive_cache_store_keys

    # defaults
    self.reactive_cache_key = -> (record) { [model_name.singular, record.id] }

    self.reactive_cache_lease_timeout = 2.minutes

    self.reactive_cache_refresh_interval = 1.minute
    self.reactive_cache_lifetime = 10.minutes

    self.reactive_cache_worker_finder = ->(id, *_args) do
      find_by(primary_key => id)
    end

    self.reactive_cache_store_keys = false

    def calculate_reactive_cache(*args)
      raise NotImplementedError
    end

    def reactive_cache_updated(*args)
    end

    def with_reactive_cache(*args, &blk)
      unless within_reactive_cache_lifetime?(*args)
        refresh_reactive_cache!(*args)
        return
      end

      keep_alive_reactive_cache!(*args)

      begin
        data = Rails.cache.read(full_reactive_cache_key(*args))
        yield data unless data.nil?
      rescue InvalidateReactiveCache
        refresh_reactive_cache!(*args)
        nil
      end
    end

    # This method is used for debugging purposes and should not be used otherwise.
    def without_reactive_cache(*args, &blk)
      return with_reactive_cache(*args, &blk) unless Rails.env.development?

      data = self.class.reactive_cache_worker_finder.call(id, *args).calculate_reactive_cache(*args)
      yield data
    end

    def clear_reactive_cache!(*args)
      Rails.cache.delete(full_reactive_cache_key(*args))
      Rails.cache.delete(alive_reactive_cache_key(*args))
    end

    def exclusively_update_reactive_cache!(*args)
      locking_reactive_cache(*args) do
        key = full_reactive_cache_key(*args)

        if within_reactive_cache_lifetime?(*args)
          enqueuing_update(*args) do
            new_value = calculate_reactive_cache(*args)
            old_value = Rails.cache.read(key)
            Rails.cache.write(key, new_value)
            reactive_cache_updated(*args) if new_value != old_value
            write_reactive_set_cache!(*args) if reactive_cache_store_keys
          end
        else
          Rails.cache.delete(key)
        end
      end
    end

    def write_reactive_set_cache!(key=nil, value=nil)
      return if key.blank? || value.blank?
      cache_key = full_reactive_cache_key(key)

      reactive_set_cache(cache_key)
        .write("#{cache_key}:#{value}")
    end

    def clear_reactive_set_cache!(key)
      return if key.blank?
      cache_key = full_reactive_cache_key(key)

      reactive_set_cache(cache_key)
        .clear_cache!
    end

    private

    def reactive_set_cache(cache_key)
      Gitlab::ReactiveCacheSetCache.new(cache_key, expires_in: reactive_cache_lifetime)
    end

    def refresh_reactive_cache!(*args)
      clear_reactive_cache!(*args)
      keep_alive_reactive_cache!(*args)
      ReactiveCachingWorker.perform_async(self.class, id, *args)
    end

    def keep_alive_reactive_cache!(*args)
      Rails.cache.write(alive_reactive_cache_key(*args), true, expires_in: self.class.reactive_cache_lifetime)
    end

    def full_reactive_cache_key(*qualifiers)
      prefix = self.class.reactive_cache_key
      prefix = prefix.call(self) if prefix.respond_to?(:call)

      ([prefix].flatten + qualifiers).join(':')
    end

    def alive_reactive_cache_key(*qualifiers)
      full_reactive_cache_key(*(qualifiers + ['alive']))
    end

    def locking_reactive_cache(*args)
      lease = Gitlab::ExclusiveLease.new(full_reactive_cache_key(*args), timeout: reactive_cache_lease_timeout)
      uuid = lease.try_obtain
      yield if uuid
    ensure
      Gitlab::ExclusiveLease.cancel(full_reactive_cache_key(*args), uuid)
    end

    def within_reactive_cache_lifetime?(*args)
      Rails.cache.exist?(alive_reactive_cache_key(*args))
    end

    def enqueuing_update(*args)
      yield

      ReactiveCachingWorker.perform_in(self.class.reactive_cache_refresh_interval, self.class, id, *args)
    end
  end
end
