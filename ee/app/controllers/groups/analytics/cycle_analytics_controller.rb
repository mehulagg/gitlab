# frozen_string_literal: true

class Groups::Analytics::CycleAnalyticsController < Groups::Analytics::ApplicationController
  include Analytics::UniqueVisitsHelper
  include CycleAnalyticsParams
  extend ::Gitlab::Utils::Override

  increment_usage_counter Gitlab::UsageDataCounters::CycleAnalyticsCounter, :views, only: :show

  before_action :load_group, only: :show
  before_action :load_project, only: :show
  before_action :load_value_stream, only: :show
  before_action :request_params, only: :show

  before_action do
    push_frontend_feature_flag(:cycle_analytics_scatterplot_enabled, default_enabled: true)
    push_frontend_feature_flag(:value_stream_analytics_path_navigation, @group)
    push_frontend_feature_flag(:value_stream_analytics_extended_form, @group)
    render_403 unless can?(current_user, :read_group_cycle_analytics, @group)
  end

  layout 'group'

  track_unique_visits :show, target_id: 'g_analytics_valuestream'

  private

  override :all_cycle_analytics_params
  def all_cycle_analytics_params
    super.merge({ group: @group, value_stream: @value_stream })
  end

  def load_value_stream
    return unless @group && params[:value_stream_id]

    @value_stream = @group.value_streams.find(params[:value_stream_id])
  end
end
