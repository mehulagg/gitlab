# frozen_string_literal: true

class Groups::EmailCampaignsController < Groups::ApplicationController
  include InProductMarketingHelper
  include Gitlab::Tracking::ControllerConcern

  SURVEY_RESPONSE_SCHEMA_URL = 'iglu:com.gitlab/survey_response/jsonschema/1-0-0'

  feature_category :navigation

  before_action :check_params

  def index
    track_click
    redirect_to params[:redirect_link]
  end

  private

  def track_click
    data = {
      namespace_id: group.id,
      track: params[:track],
      series: params[:series],
      subject_line: subject_line(params[:track].to_sym, params[:series].to_i)
    }

    track_self_describing_event(SURVEY_RESPONSE_SCHEMA_URL, data: data)
  end

  def check_params
    track = params[:track]&.to_sym
    series = params[:series]&.to_i

    track_valid = track.in?(Namespaces::InProductMarketingEmailsService::TRACKS.keys)
    series_valid = series.in?(0..Namespaces::InProductMarketingEmailsService::INTERVAL_DAYS.size - 1)

    render_404 unless track_valid && series_valid
  end
end
