# frozen_string_literal: true

class Groups::Analytics::RepositoryAnalyticsController < Groups::Analytics::ApplicationController
  check_feature_flag Gitlab::Analytics::GROUP_COVERAGE_REPORTS_FEATURE_FLAG

  layout 'group'

  before_action :load_group
  before_action -> { check_feature_availability!(:group_repository_analytics) }
  before_action -> { authorize_view_by_action!(:read_group_repository_analytics) }

  def show
    track_event(pageview_tracker_params)
  end

  private

  def pageview_tracker_params
    {
      label: 'group_id',
      value: @group.id
    }
  end
end
