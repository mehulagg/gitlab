# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'registrations/welcome/continuous_onboarding_getting_started' do
  describe 'project import state' do
    let(:project) { create(:project) }

    subject { rendered }

    before do
      allow(view).to receive(:project).and_return(project)
      allow(view).to receive(:learn_gitlab_onboarding_available?).and_return(project_available)

      render
    end

    context 'when onboarding project is ready' do
      let(:project_available) { true }

      it { is_expected.to have_content("Ok, let's go") }
      it { is_expected.not_to have_content('Creating your onboarding experience...') }
    end

    context 'when onboarding project is not yet ready' do
      let(:project_available) { false }

      it { is_expected.not_to have_content("Ok, let's go") }
      it { is_expected.to have_content('Creating your onboarding experience...') }
    end
  end
end
