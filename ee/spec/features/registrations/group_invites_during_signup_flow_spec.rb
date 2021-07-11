# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User is able to invite members to group during signup', :js, :experiment do
  include Select2Helper

  let_it_be(:user) { create(:user, setup_for_company: true) }

  let(:path_params) { {} }

  before do
    allow(Gitlab).to receive(:dev_env_or_com?).and_return(true)
    sign_in(user)
  end

  context 'when all feature flags are enabled in group creation' do
    it 'shows and allows inviting of users on separate screen' do
      invite_email = 'bob@example.com'

      create_group_through_form

      expect_group_invites_page

      fill_in 'Email 1', with: invite_email

      click_on 'Send invitations'

      aggregate_failures do
        expect(page).to have_content('Create/import your first project')
        expect(Member.last.invite_email).to eq invite_email
      end
    end

    it 'allows skipping inviting members' do
      create_group_through_form

      expect_group_invites_page

      click_on 'Skip this for now'

      expect(page).to have_content('Create/import your first project')
    end
  end

  it 'validates group invites are displayed as separate page' do
    create_group_through_form

    expect_group_invites_page
  end

  context 'when in trial_onboarding_flow' do
    let(:path_params) { { trial_onboarding_flow: true } }

    it 'validates group invites are displayed as separate page' do
      expect_next_instance_of(GitlabSubscriptions::ApplyTrialService) do |service|
        expect(service).to receive(:execute).and_return({ success: true })
      end

      create_group_through_form

      expect_group_invites_page
    end
  end

  context 'when in trial_during_signup_flow' do
    let(:path_params) { { trial: true } }

    it 'validates group invites are displayed as separate page', :aggregate_failures do
      expect_next_instance_of(GitlabSubscriptions::CreateLeadService) do |service|
        expect(service).to receive(:execute).and_return(success: true)
      end
      expect_next_instance_of(GitlabSubscriptions::ApplyTrialService) do |service|
        expect(service).to receive(:execute).and_return({ success: true })
      end

      create_group_for_trial

      expect_group_invites_page
      expect_group_invites_with_trial_activation
    end
  end

  def create_group_for_trial
    visit new_users_sign_up_group_path(path_params)

    fill_in 'group_name', with: 'test'

    fill_in 'company_name', with: 'GitLab'
    select2 '1-99', from: '#company_size'
    fill_in 'number_of_users', with: '1'
    fill_in 'phone_number', with: '+1234567890'
    select2 'US', from: '#country_select'

    click_on 'Create group'
  end

  def create_group_through_form
    visit new_users_sign_up_group_path(path_params)

    fill_in 'group_name', with: 'test'

    click_on 'Create group'
  end

  def expect_group_invites_page
    expect(page).to have_content('Invite your teammates')
  end

  def expect_group_invites_with_trial_activation
    expect_group_invites_page
    expect(page).to have_content('Congratulations, your free trial is activated.')
  end
end
