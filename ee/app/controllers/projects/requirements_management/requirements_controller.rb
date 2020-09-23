# frozen_string_literal: true

class Projects::RequirementsManagement::RequirementsController < Projects::ApplicationController
  before_action :authorize_read_requirement!
  before_action :verify_requirements_management_flag!
  before_action do
    push_frontend_feature_flag(:requirements_management, project, default_enabled: true)
  end

  def index
    respond_to do |format|
      format.html
    end
  end

  private

  def verify_requirements_management_flag!
    render_404 unless Feature.enabled?(:requirements_management, project, default_enabled: true)
  end
end
