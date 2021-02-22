# frozen_string_literal: true

module Namespaces
  class LearnGitlabExperiment
    def initialize(user, namespace)
      @user = user
      @namespace = namespace
    end

    def enabled?
      return false unless user
      return false unless enabled_for_user?

      learn_gitlab_onboarding_available?
    end

    def foo
    end

    private

    attr_reader :user, :namespace

    def enabled_for_user?
      Gitlab::Experimentation.in_experiment_group?(:learn_gitlab_a, subject: user) ||
        Gitlab::Experimentation.in_experiment_group?(:learn_gitlab_b, subject: user)
    end

    def learn_gitlab_onboarding_available?
      OnboardingProgress.onboarding?(namespace) && LearnGitlab.new(user).available?
    end
  end
end
