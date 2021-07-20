# frozen_string_literal: true

module CycleAnalyticsParams
  extend ActiveSupport::Concern

  def cycle_analytics_project_params
    return {} unless params[:cycle_analytics].present?

    params[:cycle_analytics].permit(:start_date, :created_after, :created_before, :branch_name)
  end

  def cycle_analytics_group_params
    return {} unless params.present?

    params.permit(:group_id, :start_date, :created_after, :created_before, project_ids: [])
  end

  def options(params)
    @options ||= { from: start_date(params), current_user: current_user }.merge(date_range(params))
  end

  def start_date(params)
    case params[:start_date]
    when '7'
      7.days.ago
    when '30'
      30.days.ago
    else
      90.days.ago
    end
  end

  def date_range(params)
    {}.tap do |date_range_params|
      date_range_params[:from] = to_utc_time(params[:created_after]).beginning_of_day if params[:created_after]
      date_range_params[:to] = to_utc_time(params[:created_before]).end_of_day if params[:created_before]
    end.compact
  end

  def to_utc_time(field)
    date = field.is_a?(Date) || field.is_a?(Time) ? field : Date.parse(field)
    date.to_time.utc
  end

  private

  def permitted_cycle_analytics_params
    params.permit(*::Gitlab::Analytics::CycleAnalytics::RequestParams::STRONG_PARAMS_DEFINITION)
  end

  def all_cycle_analytics_params
    permitted_cycle_analytics_params.merge(current_user: current_user)
  end

  def request_params
    @request_params ||= ::Gitlab::Analytics::CycleAnalytics::RequestParams.new(all_cycle_analytics_params)
  end

  def validate_params
    if request_params.invalid?
      render(
        json: { message: 'Invalid parameters', errors: request_params.errors },
        status: :unprocessable_entity
      )
    end
  end
end

CycleAnalyticsParams.prepend_mod_with('CycleAnalyticsParams')
