# frozen_string_literal: true

class Projects::Ci::PipelineEditorController < Projects::ApplicationController
  before_action :authorize_read_pipeline!
  before_action :authorize_create_pipeline!
  before_action :authorize_update_pipeline!

  feature_category :pipeline_authoring

  def show
    render_404 unless ::Gitlab::Ci::Features.ci_pipeline_editor_page_enabled?(@project)
  end
end
