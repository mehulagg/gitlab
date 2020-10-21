# frozen_string_literal: true

class Projects::Analytics::MergeRequestAnalyticsController < Projects::ApplicationController
  include Analytics::UniqueVisitsHelper

  before_action :authorize_read_project_merge_request_analytics!

  track_unique_visits :show, target_id: 'p_analytics_merge_request'

  feature_category :planning_analytics

  def show
  end
end
