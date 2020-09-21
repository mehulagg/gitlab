# frozen_string_literal: true

module WhatsNewHelper
  include Gitlab::WhatsNew
  include Gitlab::Utils::StrongMemoize

  def whats_new_most_recent_release_items_count
    items = parsed_most_recent_release_items

    return unless items.is_a?(Array)

    items.count
  end

  def whats_new_storage_key
    strong_memoize(:whats_new_storage_key) do
      items = parsed_most_recent_release_items

      return unless items.is_a?(Array)

      release = items.first.try(:[], 'release')

      ['display-whats-new-notification', release].compact.join('-')
    end
  end

  private

  def parsed_most_recent_release_items
    strong_memoize(:parsed_most_recent_release_items) do
      Gitlab::Json.parse(whats_new_most_recent_release_items)
    end
  end
end
