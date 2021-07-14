# frozen_string_literal: true

module Registrations
  class ProjectsController < ApplicationController
    include Registrations::ProjectsControllerConcern

    layout 'minimal'

    before_action :check_if_gl_com_or_dev
    before_action only: [:new] do
      set_namespace
      authorize_create_project!
    end

    feature_category :onboarding

    def new
      @project = Project.new(namespace: @namespace)
    end

    def create
      @project = ::Projects::CreateService.new(current_user, project_params).execute

      if @project.saved?
        learn_gitlab_project = create_learn_gitlab_project
        onboarding_context = {
          namespace_id: learn_gitlab_project.namespace_id,
          project_id: @project.id,
          learn_gitlab_project_id: learn_gitlab_project.id
        }

        experiment(:jobs_to_be_done, user: current_user)
          .track(:create_project, project: @project)

        if helpers.in_trial_onboarding_flow?
          record_experiment_user(:trial_onboarding_issues, onboarding_context)
          record_experiment_conversion_event(:trial_onboarding_issues)

          redirect_to trial_getting_started_users_sign_up_welcome_path(learn_gitlab_project_id: learn_gitlab_project.id)
        else
          record_experiment_user(:learn_gitlab_a, onboarding_context)
          record_experiment_user(:learn_gitlab_b, onboarding_context)

          if continous_onboarding_experiment_enabled_for_user?
            redirect_to continuous_onboarding_getting_started_users_sign_up_welcome_path(project_id: @project.id)
          else
            redirect_to users_sign_up_experience_level_path(namespace_path: @project.namespace)
          end
        end
      else
        render :new
      end
    end
  end
end
