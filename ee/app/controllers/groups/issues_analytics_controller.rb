# frozen_string_literal: true

class Groups::IssuesAnalyticsController < Groups::ApplicationController
  include IssuableCollections
  include Analytics::UniqueVisitsHelper

  before_action :authorize_read_group!
  before_action :authorize_read_issue_analytics!

  track_unique_visits :show, target_id: 'g_analytics_issues'

  def show
    respond_to do |format|
      format.html

      format.json do
        @chart_data =
          IssuablesAnalytics.new(issuables: issuables_collection, months_back: params[:months_back]).data

        render json: @chart_data
      end
    end
  end

  private

  def authorize_read_issue_analytics!
    render_404 unless group.feature_available?(:issues_analytics)
  end

  def authorize_read_group!
    render_404 unless can?(current_user, :read_group, group)
  end

  def finder_type
    IssuesFinder
  end

  def default_state
    'all'
  end

  def preload_for_collection
    nil
  end
end
