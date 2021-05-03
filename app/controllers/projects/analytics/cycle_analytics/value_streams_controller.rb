# frozen_string_literal: true

class Projects::Analytics::CycleAnalytics::ValueStreamsController < Projects::ApplicationController
  respond_to :json

  before_action :authorize_read_cycle_analytics!

  def index
    value_streams = [
      Analytics::CycleAnalytics::ProjectValueStream.new(
        name: Analytics::CycleAnalytics::Stages::BaseService::DEFAULT_VALUE_STREAM_NAME,
        project: @project
      )
    ]
    
    render json: Analytics::CycleAnalytics::ValueStreamSerializer.new.represent(value_streams)
  end
end
