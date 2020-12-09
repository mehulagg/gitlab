# frozen_string_literal: true

class Groups::Analytics::CiCdAnalyticsController < Groups::Analytics::ApplicationController
  before_action :load_group
  before_action -> { check_feature_availability!(:group_ci_cd_analytics) }
  before_action -> { authorize_view_by_action!(:view_group_ci_cd_analytics) }

  def show
    render_404 unless Feature.enabled?(:group_ci_cd_analytics_page, @group)
  end
end
