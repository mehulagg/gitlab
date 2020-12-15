# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Registrations::GroupsController do
  let_it_be(:user) { create(:user) }

  describe 'GET #new' do
    subject { get :new }

    context 'with an unauthenticated user' do
      it { is_expected.to have_gitlab_http_status(:redirect) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context 'with an authenticated user' do
      before do
        sign_in(user)
        stub_experiment_for_subject(onboarding_issues: true)
      end

      it { is_expected.to have_gitlab_http_status(:ok) }
      it { is_expected.to render_template(:new) }

      it 'assigns the group variable to a new Group with the default group visibility' do
        subject
        expect(assigns(:group)).to be_a_new(Group)

        expect(assigns(:group).visibility_level).to eq(Gitlab::CurrentSettings.default_group_visibility)
      end

      context 'user without the ability to create a group' do
        let(:user) { create(:user, can_create_group: false) }

        it { is_expected.to have_gitlab_http_status(:not_found) }
      end

      context 'with the experiment not enabled for user' do
        before do
          stub_experiment_for_subject(onboarding_issues: false)
        end

        it { is_expected.to have_gitlab_http_status(:not_found) }
      end
    end
  end

  describe 'POST #create' do
    subject { post :create, params: { group: params }.merge(trial_flow_params) }

    let_it_be(:trial_onboarding_issues_enabled) { false }
    let_it_be(:trial_flow_params) { {} }
    let(:params) { { name: 'Group name', path: 'group-path', visibility_level: Gitlab::VisibilityLevel::PRIVATE, emails: ['', ''] } }

    context 'with an unauthenticated user' do
      it { is_expected.to have_gitlab_http_status(:redirect) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context 'with an authenticated user' do
      before do
        sign_in(user)
        stub_experiment_for_subject(onboarding_issues: true, trial_onboarding_issues: trial_onboarding_issues_enabled)
      end

      it 'creates a group' do
        expect { subject }.to change { Group.count }.by(1)
      end

      it { is_expected.to have_gitlab_http_status(:redirect) }
      it { is_expected.to redirect_to(new_users_sign_up_project_path(namespace_id: user.groups.last.id)) }

      it_behaves_like GroupInviteMembers

      context 'when the trial onboarding is active' do
        let_it_be(:group) { create(:group) }
        let_it_be(:trial_flow_params) { { trial_flow: true } }
        let_it_be(:trial_onboarding_issues_enabled) { true }
        let_it_be(:apply_trial_params) do
          {
            uid: user.id,
            trial_user: {
              namespace_id: group.id,
              gitlab_com_trial: true,
              sync_to_gl: true
            }
          }
        end

        it 'applies the trial to the group and redirects to the project path' do
          expect_next_instance_of(::Groups::CreateService) do |service|
            expect(service).to receive(:execute).and_return(group)
          end
          expect_next_instance_of(GitlabSubscriptions::ApplyTrialService) do |service|
            expect(service).to receive(:execute).with(apply_trial_params).and_return({ success: true })
          end
          is_expected.to redirect_to(new_users_sign_up_project_path(namespace_id: group.id, trial_flow: true))
        end
      end

      context 'when the group cannot be saved' do
        let(:params) { { name: '', path: '' } }

        it 'does not create a group' do
          expect { subject }.not_to change { Group.count }
          expect(assigns(:group).errors).not_to be_blank
        end

        it { is_expected.to have_gitlab_http_status(:ok) }
        it { is_expected.to render_template(:new) }

        context 'when the trial onboarding is active' do
          let_it_be(:group) { create(:group) }
          let_it_be(:trial_flow_params) { { trial_flow: true } }
          let_it_be(:trial_onboarding_issues_enabled) { true }

          it { is_expected.not_to receive(:apply_trial) }
          it { is_expected.to render_template(:new) }
        end
      end

      context 'with the experiment not enabled for user' do
        before do
          stub_experiment_for_subject(onboarding_issues: false)
        end

        it { is_expected.to have_gitlab_http_status(:not_found) }
      end
    end
  end
end
