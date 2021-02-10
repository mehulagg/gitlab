# frozen_string_literal: true

class UserAnalyticsEntity < Grape::Entity
  include RequestAwareEntity

  expose :username

  expose :name, as: :fullname

  expose :user_web_url do |user|
    user_path(user)
  end

  Gitlab::ContributionAnalytics::DataCollector::EVENT_TYPES.each do |event_type|
    expose event_type do |user|
      request.data_collector.totals[event_type].fetch(user.id, 0)
    end
  end
end
