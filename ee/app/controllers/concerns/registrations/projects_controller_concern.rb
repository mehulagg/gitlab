# frozen_string_literal: true

module Registrations::ProjectsControllerConcern
  LEARN_GITLAB_TEMPLATE = 'learn_gitlab.tar.gz'
  LEARN_GITLAB_ULTIMATE_TEMPLATE = 'learn_gitlab_ultimate_trial.tar.gz'

  extend ActiveSupport::Concern
  include LearnGitlabHelper

  private

  def create_learn_gitlab_project
    File.open(learn_gitlab_template_path) do |archive|
      ::Projects::GitlabProjectsImportService.new(
        current_user,
        namespace_id: @project.namespace_id,
        file: archive,
        name: learn_gitlab_project_name
      ).execute
    end
  end

  def authorize_create_project!
    access_denied! unless can?(current_user, :create_projects, @namespace)
  end

  def set_namespace
    @namespace = Namespace.find_by_id(params[:namespace_id])
  end

  def project_params
    params.require(:project).permit(project_params_attributes)
  end

  def project_params_attributes
    [
      :namespace_id,
      :name,
      :path,
      :visibility_level
    ]
  end

  def learn_gitlab_project_name
    helpers.in_trial_onboarding_flow? ? s_('Learn GitLab - Ultimate trial') : s_('Learn GitLab')
  end

  def learn_gitlab_template_path
    file = if helpers.in_trial_onboarding_flow? || learn_gitlab_experiment_enabled?
             LEARN_GITLAB_ULTIMATE_TEMPLATE
           else
             LEARN_GITLAB_TEMPLATE
           end

    Rails.root.join('vendor', 'project_templates', file)
  end

  def learn_gitlab_experiment_enabled?
    Gitlab::Experimentation.in_experiment_group?(:learn_gitlab_a, subject: current_user) ||
      Gitlab::Experimentation.in_experiment_group?(:learn_gitlab_b, subject: current_user)
  end
end
