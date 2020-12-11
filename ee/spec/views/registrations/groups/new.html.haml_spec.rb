# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'registrations/groups/new' do
  let_it_be(:user) { create(:user) }
  let_it_be(:trial_during_signup) { false }

  before do
    allow(view).to receive(:current_user).and_return(user)
    allow(Gitlab).to receive(:com?).and_return(true)
    allow(view).to receive(:experiment_enabled?).with(:trial_during_signup).and_return(trial_during_signup)
    @group = create(:group)

    render
  end

  subject { rendered }

  context 'feature flag trial_during_signup is enabled' do
    let_it_be(:trial_during_signup) { true }

    it 'shows trial form and hides invite members' do
      is_expected.to have_content('Company name')
      is_expected.not_to have_selector('.js-invite-members')
    end
  end

  context 'feature flag trial_during_signup is disabled' do
    it 'shows trial form and hides invite members' do
      is_expected.not_to have_content('Company name')
      is_expected.to have_selector('.js-invite-members')
    end
  end
end
