# frozen_string_literal: true

class Analytics::CycleAnalyticsController < Analytics::ApplicationController
  include CycleAnalyticsParams
  extend ::Gitlab::Utils::Override

  check_feature_flag Gitlab::Analytics::CYCLE_ANALYTICS_FEATURE_FLAG
  increment_usage_counter Gitlab::UsageDataCounters::CycleAnalyticsCounter, :views, only: :show

  before_action :load_group, only: :show
  before_action :load_project, only: :show
  before_action :request_params, only: :show

  before_action do
    push_frontend_feature_flag(:cycle_analytics_scatterplot_enabled, default_enabled: true)
    push_frontend_feature_flag(:value_stream_analytics_path_navigation, @group)
    push_frontend_feature_flag(:value_stream_analytics_create_multiple_value_streams, default_enabled: true)
    push_frontend_feature_flag(:analytics_similarity_search, @group, default_enabled: true)
  end

  private

  override :all_cycle_analytics_params
  def all_cycle_analytics_params
    super.merge({ group: @group })
  end
end
