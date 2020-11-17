# frozen_string_literal: true

module PersonalAccessTokens
  class RotationVerifierService
    def initialize(user)
      @user = user
    end

    # If a new token has been created after we started notifying the user about the most recently EXPIRED token,
    # rotation is NOT needed.
    # For example: If the most recent token expired on 14th of June, and user created a token anytime on or after
    # 7th of June (first notification date), no rotation is required.
    def expired?
      Rails.cache.fetch(expired_cache_key, expires_in: expires_in.minutes) do
        most_recent_expires_at = tokens_without_impersonation.not_revoked.expired.maximum(:expires_at)

        if most_recent_expires_at.nil?
          false
        else
          !tokens_without_impersonation.created_on_or_after(most_recent_expires_at - Expirable::DAYS_TO_EXPIRE).exists?
        end
      end
    end

    # If a new token has been created after we started notifying the user about the most recently EXPIRING token,
    # rotation is NOT needed.
    # User is notified about an expiring token before `days_within` (7 days) of expiry
    def expiring_soon?
      Rails.cache.fetch(expiring_cache_key, expires_in: expires_in.minutes) do
        most_recent_expires_at = tokens_without_impersonation.expires_in(Expirable::DAYS_TO_EXPIRE.days.from_now).maximum(:expires_at)

        if most_recent_expires_at.nil?
          false
        else
          !tokens_without_impersonation.created_on_or_after(most_recent_expires_at - Expirable::DAYS_TO_EXPIRE).exists?
        end
      end
    end

    def clear_cache
      Rails.cache.delete(expired_cache_key)
      Rails.cache.delete(expiring_cache_key)
    end

    private

    attr_reader :user

    NUMBER_OF_MINUTES = 60

    def expired_cache_key
      ['users', user.id, 'token_expired_rotation']
    end

    def expiring_cache_key
      ['users', user.id, 'token_expiring_rotation']
    end

    def tokens_without_impersonation
      @tokens_without_impersonation ||= user
        .personal_access_tokens
        .without_impersonation
    end

    # Expire the cache at the end of day
    # Calculates the number of minutes remaining from now until end of day
    def expires_in
      (Time.current.at_end_of_day - Time.current) / NUMBER_OF_MINUTES
    end
  end
end
