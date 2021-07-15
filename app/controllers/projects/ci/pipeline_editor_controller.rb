# frozen_string_literal: true

class Projects::Ci::PipelineEditorController < Projects::ApplicationController
  before_action :check_can_collaborate!
  before_action do
    push_frontend_feature_flag(:pipeline_editor_empty_state_action, @project, default_enabled: :yaml)
    push_frontend_feature_flag(:pipeline_editor_branch_switcher, @project, default_enabled: :yaml)
    push_frontend_feature_flag(:pipeline_editor_drawer, @project, default_enabled: :yaml)
    push_frontend_feature_flag(:schema_linting, @project, default_enabled: :yaml)
  end

  feature_category :pipeline_authoring

  def show
  end

  def templates
    permitted_params = params.permit(Gitlab::Ci::Config::Entry::TemplateMetadata::ALLOWED_KEYS.map { |k| { k => [] } }).to_h
    templates = TemplateFinder.new(:gitlab_ci_ymls, @project, { metadata: permitted_params }).execute

    respond_to do |format|
      format.json do
        render json: Ci::TemplateSerializer
                        .new(project: project, current_user: current_user)
                        .represent(templates)
      end
    end
  end

  private

  def check_can_collaborate!
    render_404 unless can_collaborate_with_project?(@project)
  end
end
