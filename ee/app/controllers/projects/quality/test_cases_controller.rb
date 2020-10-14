# frozen_string_literal: true

class Projects::Quality::TestCasesController < Projects::ApplicationController
  prepend_before_action :authenticate_user!, only: [:new]

  before_action :check_quality_management_available!
  before_action :authorize_read_issue!
  before_action :verify_test_cases_flag!
  before_action :authorize_create_issue!, only: [:new]

  before_action do
    push_frontend_feature_flag(:quality_test_cases, project)
  end

  feature_category :quality_management

  def index
    respond_to do |format|
      format.html
    end
  end

  def new
    respond_to do |format|
      format.html
    end
  end

  private

  def verify_test_cases_flag!
    render_404 unless Feature.enabled?(:quality_test_cases, project)
  end
end
