# frozen_string_literal: true

class Projects::Ci::LintsController < Projects::ApplicationController
  before_action :authorize_create_pipeline!

  def show
  end

  def create
    @content = params[:content]
    @dry_run = params[:dry_run]

    if @dry_run && Gitlab::Ci::Features.lint_creates_pipeline_with_dry_run?(@project)
      pipeline = Ci::CreatePipelineService
        .new(@project, current_user, ref: @project.default_branch)
        .execute(:push, dry_run: true, content: @content)

      @status = pipeline.error_messages.empty?
      @stages = pipeline.stages
      @errors = pipeline.error_messages.map(&:content)
      @warnings = pipeline.warning_messages.map(&:content)
    else
      result = Gitlab::Ci::YamlProcessor.new(@content, yaml_processor_options).execute

      @status = result.valid?
      @errors = result.errors
      @warnings = result.warnings

      if result.valid?
        @stages = result.stages
        @builds = result.builds
        @jobs = result.jobs
      end
    end

    render :show
  end

  private

  def yaml_processor_options
    {
      project: @project,
      user: current_user,
      sha: project.repository.commit.sha
    }
  end
end
