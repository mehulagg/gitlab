# frozen_string_literal: true

module Registrations
  class ProjectsController < ApplicationController
    layout 'checkout'

    before_action :check_experiment_enabled
    before_action :find_namespace, only: :new

    def new
      @project = Project.new(namespace: @namespace)
    end

    def create
      @project = ::Projects::CreateService.new(current_user, project_params).execute

      if @project.saved?
        create_learn_gitlab_project
        redirect_to users_sign_up_experience_level_path(namespace_path: @project.namespace)
      else
        render :new
      end
    end

    private

    def create_learn_gitlab_project
      learn_gitlab_project = File.open(learn_gitlab_template_path) do |archive|
        ::Projects::GitlabProjectsImportService.new(
          current_user,
          namespace_id: @project.namespace_id,
          file: archive,
          name: s_('Learn GitLab')
        ).execute
      end

      cookies[:onboarding_issues_settings] = { 'groups#show' => true, 'projects#show' => true, 'issues#index' => true }.to_json if learn_gitlab_project.saved?
    end

    def learn_gitlab_template_path
      Rails.root.join('vendor', 'project_templates', 'learn_gitlab.tar.gz')
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
