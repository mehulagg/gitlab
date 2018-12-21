# frozen_string_literal: true
class Groups::Security::VulnerabilitiesController < Groups::Security::ApplicationController
  HISTORY_RANGE = 3.months

  def index
    @vulnerabilities = ::Security::VulnerabilitiesFinder.new(group: group, params: finder_params)
      .execute
      .ordered
      .page(params[:page])

    respond_to do |format|
      format.json do
        render json: Vulnerabilities::OccurrenceSerializer
          .new(current_user: @current_user)
          .with_pagination(request, response)
          .represent(@vulnerabilities, preload: true)
      end
    end
  end

  def summary
    respond_to do |format|
      format.json do
        render json: VulnerabilitySummarySerializer.new.represent(group)
      end
    end
  end

  def history
    respond_to do |format|
      format.json do
        render json: Vulnerabilities::HistorySerializer.new.represent(group.all_vulnerabilities.count_by_day_and_severity(HISTORY_RANGE))
      end
    end
  end

  private

  def finder_params
    raw = params.permit(:hide_dismissed, report_type: [], project_id: [], severity: [])
    raw[:hide_dismissed] = Gitlab::Utils.to_boolean(raw[:hide_dismissed]) if raw[:hide_dismissed]
    raw
  end

  def finder_params
    raw = params.permit(:hide_dismissed, report_type: [], project_id: [], severity: [])
    raw.transform_values do |filter|
      if filter.is_a?(Array)
        filter.map { |value| value.to_i }
      else
        Gitlab::Utils.to_boolean(filter)
      end
    end
  end
end
