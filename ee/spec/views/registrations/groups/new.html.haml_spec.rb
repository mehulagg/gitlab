# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'registrations/groups/new' do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:trial_onboarding_flow) { false }

  before do
    assign(:group, group)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:in_trial_onboarding_flow?).and_return(trial_onboarding_flow)

    render
  end

  it 'shows the progress bar' do
    expect(rendered).to have_selector('#progress-bar')
  end

  context 'in trial onboarding' do
    let_it_be(:trial_onboarding_flow) { true }

    it 'hides the progress bar' do
      expect(rendered).not_to have_selector('#progress-bar')
    end
  end
end
