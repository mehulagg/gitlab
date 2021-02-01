# frozen_string_literal: true

class Projects::LearnGitlabController < Projects::ApplicationController
  before_action :check_experiment_enabled?

  def index
  end

  private

  def check_experiment_enabled?
    return if Gitlab.dev_env_or_com? &&
      (Gitlab::Experimentation.in_experiment_group?(:learn_gitlab_a, subject: current_user) ||
        Gitlab::Experimentation.in_experiment_group?(:learn_gitlab_b, subject: current_user)) &&
      OnboardingProgress.onboarded?(project.namespace)

    access_denied!
  end
end
