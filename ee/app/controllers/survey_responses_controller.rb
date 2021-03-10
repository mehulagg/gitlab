# frozen_string_literal: true

class SurveyResponsesController < ApplicationController
  SURVEY_RESPONSE_SCHEMA_URL = 'iglu:com.gitlab/survey_response/jsonschema/1-0-0'

  skip_before_action :authenticate_user!

  feature_category :navigation

  def index
    track_response if Gitlab.com?

    render layout: false
  end

  private

  def track_response
    data = {
      survey_id: to_number(params[:survey_id]),
      instance_id: to_number(params[:instance_id]),
      user_id: to_number(params[:user_id]),
      email: params[:email],
      name: params[:name],
      username: params[:username],
      response: params[:response]
    }.compact

    ::Gitlab::Tracking.self_describing_event(SURVEY_RESPONSE_SCHEMA_URL, data: data)
  end

  def to_number(param)
    param.to_i if param&.match?(/^\d+$/)
  end
end
