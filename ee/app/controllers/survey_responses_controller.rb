# frozen_string_literal: true

class SurveyResponsesController < ApplicationController
  SURVEY_RESPONSE_SCHEMA_URL = 'iglu:com.gitlab/survey_response/jsonschema/1-0-0'
  CALENDLY_INVITE_LINK = 'https://calendly.com/mkarampalas/30min'

  before_action :set_cta_link, only: :index
  before_action :track_response, only: :index

  skip_before_action :authenticate_user!

  feature_category :navigation

  def index
    render layout: false
  end

  private

  def track_response
    return unless Gitlab.com?

    data = {
      survey_id: to_number(params[:survey_id]),
      instance_id: to_number(params[:instance_id]),
      user_id: to_number(params[:user_id]),
      email: params[:email],
      name: params[:name],
      username: params[:username],
      response: params[:response]
    }.compact

    context = SnowplowTracker::SelfDescribingJson.new(SURVEY_RESPONSE_SCHEMA_URL, data)

    ::Gitlab::Tracking.event(self.class.name, 'submit_response', context: [context])
  end

  def to_number(param)
    param.to_i if param&.match?(/^\d+$/)
  end

  def set_cta_link
    return unless Gitlab.com?
    return unless params[:talk_cta].present?

    @cta_link = CALENDLY_INVITE_LINK
  end
end
