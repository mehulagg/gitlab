# frozen_string_literal: true

module WhatsNewHelper
  include Gitlab::WhatsNew

  def whats_new_most_recent_release_items_count
    Rails.cache.fetch('whats_new_most_recent_release_items_count', expires_in: CACHE_DURATION) do
      items = parsed_most_recent_release_items

      return unless items.is_a?(Array) # rubocop:disable Cop/AvoidReturnFromBlocks

      items.count
    end
  end

  def whats_new_storage_key
    Rails.cache.fetch('whats_new_storage_key', expires_in: CACHE_DURATION) do
      items = parsed_most_recent_release_items

      return unless items.is_a?(Array) # rubocop:disable Cop/AvoidReturnFromBlocks

      release = items.first.try(:[], 'release')

      ['display-whats-new-notification', release].compact.join('-')
    end
  end

  private

  def parsed_most_recent_release_items
    Rails.cache.fetch('parsed_most_recent_release_items', expires_in: CACHE_DURATION) do
      Gitlab::Json.parse(whats_new_most_recent_release_items)
    end
  end
end
