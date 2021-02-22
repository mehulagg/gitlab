# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LearnGitlabHelper do
  include AfterNextHelpers
  include Devise::Test::ControllerHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, name: LearnGitlab::PROJECT_NAME, namespace: user.namespace) }
  let_it_be(:namespace) { project.namespace }

  before do
    project.add_developer(user)

    allow(helper).to receive(:user).and_return(user)
    allow_next_instance_of(LearnGitlab) do |learn_gitlab|
      allow(learn_gitlab).to receive(:project).and_return(project)
    end

    OnboardingProgress.onboard(namespace)
    OnboardingProgress.register(namespace, :git_write)
  end

  describe '.onboarding_actions_data' do
    subject(:onboarding_actions_data) { helper.onboarding_actions_data(project) }

    it 'has all actions' do
      expect(onboarding_actions_data.keys).to contain_exactly(
        :git_write,
        :pipeline_created,
        :merge_request_created,
        :user_added,
        :trial_started,
        :required_mr_approvals_enabled,
        :code_owners_enabled,
        :security_scan_enabled
      )
    end

    it 'sets correct path and completion status' do
      expect(onboarding_actions_data[:git_write]).to eq({
        url: project_issue_url(project, LearnGitlabHelper::ACTION_ISSUE_IDS[:git_write]),
        completed: true,
        svg: helper.image_path("learn_gitlab/git_write.svg")
      })
      expect(onboarding_actions_data[:pipeline_created]).to eq({
        url: project_issue_url(project, LearnGitlabHelper::ACTION_ISSUE_IDS[:pipeline_created]),
        completed: false,
        svg: helper.image_path("learn_gitlab/pipeline_created.svg")
      })
    end
  end
end
