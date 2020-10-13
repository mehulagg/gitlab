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
        stub_experiment_for_user(onboarding_issues: true)
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
          stub_experiment_for_user(onboarding_issues: false)
        end

        it { is_expected.to have_gitlab_http_status(:not_found) }
      end
    end
  end

  describe 'POST #create' do
    subject { post :create, params: { group: params } }

    let(:params) { { name: 'Group name', path: 'group-path', visibility_level: Gitlab::VisibilityLevel::PRIVATE, emails: ['', ''] } }

    context 'with an unauthenticated user' do
      it { is_expected.to have_gitlab_http_status(:redirect) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context 'with an authenticated user' do
      before do
        sign_in(user)
        stub_experiment_for_user(onboarding_issues: true)
      end

      it 'creates a group' do
        expect { subject }.to change { Group.count }.by(1)
      end

      it { is_expected.to have_gitlab_http_status(:redirect) }
      it { is_expected.to redirect_to(new_users_sign_up_project_path(namespace_id: user.groups.last.id)) }

      context 'inviting teammates' do
        context 'with no valid emails in the params' do
          it 'does not add teammates' do
            expect { subject }.to change(Member, :count).by(1)
          end

          it 'does not call the Members::CreateService' do
            expect(Members::CreateService).not_to receive(:new)
          end
        end

        context 'with valid emails in the params' do
          before do
            params[:emails] = ['a@a.a', 'b@b.b', '', '', 'x', 'y']
          end

          it 'adds users with developer access and ignores blank emails' do
            expect_next_instance_of(Group) do |group|
              expect(group).to receive(:add_users).with(
                ['a@a.a', 'b@b.b', 'x', 'y'],
                Gitlab::Access::DEVELOPER,
                expires_at: nil,
                current_user: user
              ).and_call_original
            end

            subject
          end

          it 'sends invitations to valid emails only' do
            subject

            emails = assigns(:group).members.pluck(:invite_email)

            expect(emails).to include('a@a.a', 'b@b.b')
            expect(emails).not_to include('x', 'y')
          end
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
      end

      context 'with the experiment not enabled for user' do
        before do
          stub_experiment_for_user(onboarding_issues: false)
        end

        it { is_expected.to have_gitlab_http_status(:not_found) }
      end
    end
  end
end
