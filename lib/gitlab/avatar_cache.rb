# frozen_string_literal: true

module Gitlab
  class AvatarCache
    class << self
      # @return [Symbol]
      BASE_KEY = :avatar_cache

      # @return [ActiveSupport::Duration]
      DEFAULT_EXPIRY = 7.days

      def by_user_or_email(user:, email:, **other_opts, &block)
        return by_user(user, *other_opts.values, &block) if user.present?
        return by_email(email, *other_opts.values, &block) if email.present?

        # We shouldn't be getting to here but just in case we can return the block
        block.call
      end

      def by_user(user, *additional_keys, expires_in: DEFAULT_EXPIRY, &block)
        key = user_key(user)
        subkey = sub_key(additional_keys)

        fetch_by_subkey(key, subkey, expires_in: expires_in, &block)
      end

      # Look up cached avatar data by email address.
      # This accepts a block to provide the value to be
      # cached in the event nothing is found.
      #
      # @param email [String]
      # @param expires_in [ActiveSupport::Duration, Integer]
      # @yield [email, *additional_keys] yields the supplied params back to the block
      # @return [String]
      def by_email(email, *additional_keys, expires_in: DEFAULT_EXPIRY, &block)
        key = email_key(email)
        subkey = sub_key(additional_keys)

        fetch_by_subkey(key, subkey, expires_in: expires_in, &block)
      end

      # Remove one or more emails from the cache
      #
      # @param emails [String] one or more emails to delete
      # @return [Integer] the number of keys deleted
      def delete_by_email(*emails)
        return 0 if emails.empty?

        with do |redis|
          keys = emails.map { |email| email_key(email) }

          Gitlab::Instrumentation::RedisClusterValidator.allow_cross_slot_commands do
            redis.unlink(*keys)
          end
        end
      end

      private

      def user_key(user)
        "#{BASE_KEY}:#{user.cache_key}"
      end

      # @param email [String]
      # @return [String]
      def email_key(email)
        "#{BASE_KEY}:#{email}"
      end

      def sub_key(parts)
        parts.join(":")
      end

      def fetch_by_subkey(key, subkey, expires_in:, &block)
        with do |redis|
          # Look for existing cache value
          cached = redis.hget(key, subkey)

          # Return the cached entry if set
          break cached unless cached.nil?

          # Otherwise, call the block to get the value
          to_cache = block.call.to_s

          # Set it in the cache
          redis.hset(key, subkey, to_cache)

          # Update the expiry time
          redis.expire(key, expires_in)

          # Return this new value
          break to_cache
        end
      end

      def with(&blk)
        Gitlab::Redis::Cache.with(&blk) # rubocop:disable CodeReuse/ActiveRecord
      end
    end
  end
end
