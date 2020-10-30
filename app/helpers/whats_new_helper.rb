# frozen_string_literal: true

module WhatsNewHelper
  def whats_new_most_recent_release_items_count
    Gitlab::ProcessMemoryCache.cache_backend.fetch('whats_new:release_items_count', expires_in: ReleaseHighlight::CACHE_DURATION) do
      most_recent = ReleaseHighlight.paginated

      most_recent&.[](:items)&.count
    end
  end

  def whats_new_storage_key
    return unless whats_new_most_recent_version

    ['display-whats-new-notification', whats_new_most_recent_version].join('-')
  end

  private

  def whats_new_most_recent_version
    Gitlab::ProcessMemoryCache.cache_backend.fetch('whats_new:release_version', expires_in: ReleaseHighlight::CACHE_DURATION) do
      most_recent = ReleaseHighlight.paginated

      most_recent&.[](:items)&.first&.[]('release')
    end
  end
end
