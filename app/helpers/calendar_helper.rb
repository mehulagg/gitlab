# frozen_string_literal: true

module CalendarHelper
  def calendar_url_options
    feed_token = Settings[:feed_token_off] ? nil : current_user.try(:feed_token)
    { format: :ics,
      feed_token: feed_token,
      due_date: Issue::DueNextMonthAndPreviousTwoWeeks.name,
      sort: 'closest_future_date' }
  end
end
