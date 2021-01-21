# frozen_string_literal: true

class Groups::Analytics::RepositoryAnalyticsController < Groups::Analytics::ApplicationController
  include RedisTracking
  layout 'group'

  before_action :load_group
  before_action -> { check_feature_availability!(:group_repository_analytics) }
  before_action -> { authorize_view_by_action!(:read_group_repository_analytics) }
  track_redis_hll_event :show, name: 'i_testing_group_code_coverage_visit_total', feature: :usage_data_i_testing_group_code_coverage_visit_total, feature_default_enabled: true

  def show
    track_event(**pageview_tracker_params)
  end

  private

  def pageview_tracker_params
    {
      label: 'group_id',
      value: @group.id
    }
  end
end
