# frozen_string_literal: true

class Projects::Ci::DailyBuildGroupReportResultsController < Projects::ApplicationController
  include Gitlab::Utils::StrongMemoize

  before_action :authorize_read_build_report_results!
  before_action :validate_param_type!

  feature_category :continuous_integration

  def index
    respond_to do |format|
      format.csv { send_data(render_csv(report_results), type: 'text/csv; charset=utf-8') }
      format.json { render json: render_json(report_results) }
    end
  end

  private

  def validate_param_type!
    respond_422 unless allowed_param_types.include?(param_type)
  end

  def render_csv(collection)
    CsvBuilders::SingleBatch.new(
      collection,
      {
        date: 'date',
        group_name: 'group_name',
        param_type => -> (record) { record.data[param_type] }
      }
    ).render
  end

  def render_json(collection)
    Ci::DailyBuildGroupReportResultSerializer.new.represent(collection, param_type: param_type)
  end

  def report_results
    Ci::DailyBuildGroupReportResultsFinder.new(params, current_user: current_user).execute
  end

  def params
    {
      project: project,
      # project_ids: [project.id],
      # coverage: true,
      ref_path: params[:ref_path],
      start_date: start_date,
      limit: Ci::DailyBuildGroupReportResult::MAX_ITEMS
    }
  end

  def allowed_param_types
    Ci::DailyBuildGroupReportResult::PARAM_TYPES
  end

  def param_type
    params.require(:param_type)
  end
end
