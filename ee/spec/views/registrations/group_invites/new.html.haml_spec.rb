# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'registrations/group_invites/new' do
  let(:group) { build(:group) }
  let(:trial_onboarding_flow) { false }

  before do
    assign(:group, group)
    allow(view).to receive(:in_trial_onboarding_flow?).and_return(trial_onboarding_flow)
    allow(view).to receive(:in_trial_during_signup_flow?).and_return(true)

    render
  end

  it 'shows standard markup', :aggregate_failures do
    expect(rendered).to have_selector('#progress-bar')
    expect(rendered).to have_content('Invite your teammates')
    expect(rendered).to have_link('Skip this for now')
    expect(rendered).to have_content("Don't worry, you can always invite teammates later")
  end

  context 'in trial onboarding' do
    let(:trial_onboarding_flow) { true }

    it 'show the trial activation' do
      expect(rendered).to have_content('Congratulations, your free trial is activated.')
    end
  end

  context 'in trial flow' do
    it 'show the trial activation' do
      expect(rendered).to have_content('Congratulations, your free trial is activated.')
    end
  end
end
