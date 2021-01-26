# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'trials/_skip_trial.html.haml' do
  include ApplicationHelper

  let_it_be(:trimmed_skip_trial_copy_enabled) { false }
  let(:source) { nil }

  before do
    allow(view).to receive(:experiment_enabled?).with(:trimmed_skip_trial_copy).and_return(trimmed_skip_trial_copy_enabled)
    params[:glm_source] = source
    render 'trials/skip_trial'
  end

  subject { rendered }

  shared_examples 'has Skip Trial verbiage' do
    it { is_expected.to have_content("Skip Trial (Continue with Free Account)") }
  end

  context 'without glm_source' do
    include_examples 'has Skip Trial verbiage'
  end

  context 'with glm_source of about.gitlab.com' do
    let(:source) { 'about.gitlab.com' }

    include_examples 'has Skip Trial verbiage'

    context 'when trimmed_skip_trial_copy experiment is enabled' do
      let_it_be(:trimmed_skip_trial_copy_enabled) { true }

      it { is_expected.to have_content("Skip Trial") }
    end
  end

  context 'with glm_source of gitlab.com' do
    let(:source) { 'gitlab.com' }

    it { is_expected.to have_content("Go back to GitLab") }
  end
end
