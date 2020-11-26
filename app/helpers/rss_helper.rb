# frozen_string_literal: true

module RssHelper
  def rss_url_options
    feed_token = Settings[:feed_token_off] ? nil : current_user.try(:feed_token)
    { format: :atom, feed_token: feed_token }
  end
end
