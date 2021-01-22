# frozen_string_literal: true

module Registrations
  class ProjectsController < ApplicationController
    layout 'checkout'

    before_action :check_experiment_enabled
    before_action :find_namespace, only: :new

    feature_category :navigation

    def new
      @project = Project.new(namespace: @namespace)
    end

    def create
      @project = ::Projects::CreateService.new(current_user, project_params).execute

      if @project.saved?
        learn_gitlab_project = create_learn_gitlab_project

        if helpers.in_trial_onboarding_flow?
          trial_onboarding_context = {
            namespace_id: learn_gitlab_project.namespace_id,
            project_id: @project.id,
            learn_gitlab_project_id: learn_gitlab_project.id
          }

          record_experiment_user(:trial_onboarding_issues, trial_onboarding_context)
          redirect_to trial_getting_started_users_sign_up_welcome_path(learn_gitlab_project_id: learn_gitlab_project.id)
        else
          redirect_to users_sign_up_experience_level_path(namespace_path: @project.namespace, trial_onboarding_flow: params[:trial_onboarding_flow])
        end
      else
        render :new
      end
    end

    private

    def create_learn_gitlab_project
      title, filename = if helpers.in_trial_onboarding_flow?
                          [s_('Learn GitLab - Gold trial'), 'learn_gitlab_gold_trial.tar.gz']
                        else
                          [s_('Learn GitLab'), 'learn_gitlab.tar.gz']
                        end

      learn_gitlab_template_path = Rails.root.join('vendor', 'project_templates', filename)

      learn_gitlab_project = File.open(learn_gitlab_template_path) do |archive|
        ::Projects::GitlabProjectsImportService.new(
          current_user,
          namespace_id: @project.namespace_id,
          file: archive,
          name: title
        ).execute
      end

      cookies[:onboarding_issues_settings] = { 'groups#show' => true, 'projects#show' => true, 'issues#index' => true }.to_json if learn_gitlab_project.saved? && !helpers.in_trial_onboarding_flow?

      learn_gitlab_project
    end

    def check_experiment_enabled
      access_denied! unless experiment_enabled?(:onboarding_issues)
    end

    def find_namespace
      @namespace = Namespace.find_by_id(params[:namespace_id])

      access_denied! unless can?(current_user, :create_projects, @namespace)
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
  end
end
