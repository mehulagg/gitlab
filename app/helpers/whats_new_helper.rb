# frozen_string_literal: true

module WhatsNewHelper
  include Gitlab::WhatsNew

  def whats_new_most_recent_release_items_count
    Rails.cache.fetch('whats_new:release_items_count', expires_in: CACHE_DURATION) do
      parsed_most_recent_release_items&.count
    end
  end

  def whats_new_storage_key
    Rails.cache.fetch('whats_new:storage_key', expires_in: CACHE_DURATION) do
      if parsed_most_recent_release_items
        release = parsed_most_recent_release_items.first.try(:[], 'release')

        ['display-whats-new-notification', release].compact.join('-')
      end
    end
  end

  private

  def parsed_most_recent_release_items
    Rails.cache.fetch('whats_new:parsed_release_items', expires_in: CACHE_DURATION) do
      items = Gitlab::Json.parse(whats_new_release_items)

      items if items.is_a?(Array)
    end
  end
end
