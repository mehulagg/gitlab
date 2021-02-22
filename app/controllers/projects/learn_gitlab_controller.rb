# frozen_string_literal: true

class Projects::LearnGitlabController < Projects::ApplicationController
  before_action :authenticate_user!
  before_action :check_experiment_enabled?

  feature_category :users

  def index
    push_frontend_experiment(:learn_gitlab_a, subject: current_user)
    push_frontend_experiment(:learn_gitlab_b, subject: current_user)
  end

  private

  def check_experiment_enabled?
    return access_denied! unless Namespaces::LearnGitlabExperiment.new(current_user, project.namespace).enabled?
  end
end
