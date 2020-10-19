# frozen_string_literal: true

class Projects::PipelineAuthoringController < Projects::ApplicationController
  before_action :authorize_read_pipeline!
  before_action :authorize_create_pipeline!, only: [:new, :create, :config_variables]
  before_action :authorize_update_pipeline!, only: [:retry, :cancel]

  def index
    return render_404 unless Feature.enabled?(:ci_pipeline_authoring_page, @project)
  end
end
