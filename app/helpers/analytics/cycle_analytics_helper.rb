# frozen_string_literal: true

module Analytics
  module CycleAnalyticsHelper
    def cycle_analytics_default_stage_config
      Gitlab::Analytics::CycleAnalytics::DefaultStages.all.map do |s|
        Analytics::CycleAnalytics::StagePresenter.new(s).as_json
      end
    end
  end
end
