# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Registrations::GroupsController do
  let_it_be(:user) { create(:user) }

  shared_examples 'hides email confirmation warning' do
    RSpec::Matchers.define :set_confirm_warning_for do |email|
      match do |response|
        expect(response).to set_flash.now[:warning].to include("Please check your email (#{email}) to verify that you own this address and unlock the power of CI/CD.")
      end
    end

    context 'with an unconfirmed email address present' do
      let(:user) { create(:user, confirmed_at: nil, unconfirmed_email: 'unconfirmed@gitlab.com') }

      it { is_expected.not_to set_confirm_warning_for(user.unconfirmed_email) }
    end

    context 'without an unconfirmed email address present' do
      let(:user) { create(:user, confirmed_at: nil) }

      it { is_expected.not_to set_confirm_warning_for(user.email) }
    end
  end

  describe 'GET #new' do
    let(:signup_onboarding_enabled) { true }

    subject { get :new }

    context 'with an unauthenticated user' do
      it { is_expected.to have_gitlab_http_status(:redirect) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context 'with an authenticated user' do
      before do
        sign_in(user)
        allow(controller.helpers).to receive(:signup_onboarding_enabled?).and_return(signup_onboarding_enabled)
      end

      it { is_expected.to have_gitlab_http_status(:ok) }
      it { is_expected.to render_template(:new) }

      it 'assigns the group variable to a new Group with the default group visibility' do
        subject
        expect(assigns(:group)).to be_a_new(Group)

        expect(assigns(:group).visibility_level).to eq(Gitlab::CurrentSettings.default_group_visibility)
      end

      it 'calls the record user method for trial_during_signup experiment' do
        expect(controller).to receive(:record_experiment_user).with(:trial_during_signup)

        subject
      end

      context 'user without the ability to create a group' do
        let(:user) { create(:user, can_create_group: false) }

        it { is_expected.to have_gitlab_http_status(:not_found) }
      end

      context 'signup onboarding not enabled' do
        let(:signup_onboarding_enabled) { false }

        it { is_expected.to have_gitlab_http_status(:not_found) }
      end

      it_behaves_like 'hides email confirmation warning'
    end
  end

  describe 'POST #create' do
    let_it_be(:glm_params) { {} }
    let_it_be(:trial_form_params) { { trial: 'false' } }
    let_it_be(:trial_onboarding_issues_enabled) { false }
    let_it_be(:trial_onboarding_flow_params) { {} }
    let(:signup_onboarding_enabled) { true }
    let(:group_params) { { name: 'Group name', path: 'group-path', visibility_level: Gitlab::VisibilityLevel::PRIVATE, emails: ['', ''] } }
    let(:params) do
      { group: group_params }.merge(glm_params).merge(trial_form_params).merge(trial_onboarding_flow_params)
    end

    subject { post :create, params: params }

    context 'with an unauthenticated user' do
      it { is_expected.to have_gitlab_http_status(:redirect) }
      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context 'with an authenticated user' do
      before do
        sign_in(user)
        stub_experiment_for_subject(trial_onboarding_issues: trial_onboarding_issues_enabled)
        allow(controller.helpers).to receive(:signup_onboarding_enabled?).and_return(signup_onboarding_enabled)
      end

      it_behaves_like 'hides email confirmation warning'

      context 'when signup onboarding is not enabled' do
        let(:signup_onboarding_enabled) { false }

        it { is_expected.to have_gitlab_http_status(:not_found) }
      end

      context 'when group can be created' do
        it 'creates a group' do
          expect { subject }.to change { Group.count }.by(1)
        end

        context 'when the trial onboarding is active - apply_trial_for_trial_onboarding_flow' do
          let_it_be(:group) { create(:group) }
          let_it_be(:trial_onboarding_flow_params) { { trial_onboarding_flow: true, glm_source: 'about.gitlab.com', glm_content: 'content' } }
          let_it_be(:trial_onboarding_issues_enabled) { true }
          let_it_be(:apply_trial_params) do
            {
              uid: user.id,
              trial_user: ActionController::Parameters.new(
                {
                  glm_source: 'about.gitlab.com',
                  glm_content: 'content',
                  namespace_id: group.id,
                  gitlab_com_trial: true,
                  sync_to_gl: true
                }
              ).permit!
            }
          end

          before do
            expect_next_instance_of(::Groups::CreateService) do |service|
              expect(service).to receive(:execute).and_return(group)
            end
          end

          context 'when trial can be applied' do
            before do
              expect_next_instance_of(GitlabSubscriptions::ApplyTrialService) do |service|
                expect(service).to receive(:execute).with(apply_trial_params).and_return({ success: true })
              end
              expect(controller).to receive(:record_experiment_user).with(:remove_known_trial_form_fields, namespace_id: group.id)
              expect(controller).to receive(:record_experiment_user).with(:trial_onboarding_issues, namespace_id: group.id)
              expect(controller).to receive(:record_experiment_conversion_event).with(:remove_known_trial_form_fields)
              expect(controller).to receive(:record_experiment_conversion_event).with(:trial_onboarding_issues)
            end

            context 'when registration_group_invite experiment is enabled' do
              before do
                stub_experiments(registrations_group_invite: :invite_page)
              end

              it { is_expected.to redirect_to(new_users_sign_up_group_invite_path(group_id: group.id, trial: false, trial_onboarding_flow: true)) }
            end

            context 'when registration_group_invite experiment is disabled' do
              before do
                stub_experiments(registrations_group_invite: :control)
              end

              it { is_expected.to redirect_to(new_users_sign_up_project_path(namespace_id: group.id, trial: false, trial_onboarding_flow: true)) }
            end
          end

          context 'when failing to apply trial' do
            before do
              expect_next_instance_of(GitlabSubscriptions::ApplyTrialService) do |service|
                expect(service).to receive(:execute).with(apply_trial_params).and_return({ success: false })
              end
            end

            it { is_expected.to render_template(:new) }
          end
        end

        context 'when not in the trial onboarding - registration_onboarding_flow' do
          let_it_be(:group) { create(:group) }

          it 'calls the record user trial_during_signup experiment' do
            expect_next_instance_of(Groups::CreateService) do |service|
              expect(service).to receive(:execute).and_return(group)
            end
            expect(controller).to receive(:record_experiment_user).with(:trial_during_signup, trial_chosen: false, namespace_id: group.id)

            subject
          end

          context 'when in experiment group for trial_during_signup - trial_during_signup_flow' do
            let_it_be(:glm_params) { { glm_source: 'gitlab.com', glm_content: 'content' } }
            let_it_be(:trial_form_params) do
              {
                trial: 'true',
                company_name: 'ACME',
                company_size: '1-99',
                phone_number: '11111111',
                number_of_users: '17',
                country: 'Norway'
              }
            end

            let_it_be(:trial_user_params) do
              {
                work_email: user.email,
                first_name: user.first_name,
                last_name: user.last_name,
                uid: user.id,
                skip_email_confirmation: true,
                gitlab_com_trial: true,
                provider: 'gitlab',
                newsletter_segment: user.email_opted_in
              }
            end

            let_it_be(:trial_params) do
              {
                trial_user: ActionController::Parameters.new(trial_form_params.except(:trial).merge(trial_user_params)).permit!
              }
            end

            let_it_be(:apply_trial_params) do
              {
                uid: user.id,
                trial_user: ActionController::Parameters.new(
                  {
                    glm_source: 'gitlab.com',
                    glm_content: 'content',
                    namespace_id: group.id,
                    gitlab_com_trial: true,
                    sync_to_gl: true
                  }
                ).permit!
              }
            end

            before do
              allow(controller).to receive(:experiment_enabled?).with(:trial_during_signup).and_return(true)
            end

            context 'when a user chooses a trial - create_lead_and_apply_trial_flow' do
              context 'when successfully creating a lead and applying trial' do
                before do
                  expect_next_instance_of(Groups::CreateService) do |service|
                    expect(service).to receive(:execute).and_return(group)
                  end
                  expect_next_instance_of(GitlabSubscriptions::CreateLeadService) do |service|
                    expect(service).to receive(:execute).with(trial_params).and_return(success: true)
                  end
                  expect_next_instance_of(GitlabSubscriptions::ApplyTrialService) do |service|
                    expect(service).to receive(:execute).with(apply_trial_params).and_return({ success: true })
                  end
                end

                context 'with registrations_group_invite experiment' do
                  it 'tracks experiment as expected', :experiment do
                    expect(experiment(:registrations_group_invite))
                      .to track(:created, { property: group.id.to_s })
                            .on_next_instance
                            .with_context(actor: user)

                    subject
                  end

                  context 'when registrations_group_invite invite_page path is taken' do
                    before do
                      stub_experiments(registrations_group_invite: :invite_page)
                    end

                    it { is_expected.to redirect_to(new_users_sign_up_group_invite_path(group_id: group.id, trial: true)) }
                  end

                  context 'when registrations_group_invite experiment control path is taken' do
                    before do
                      stub_experiments(registrations_group_invite: :control)
                    end

                    it { is_expected.to redirect_to(new_users_sign_up_project_path(namespace_id: group.id, trial: true)) }
                  end
                end
              end

              context 'when failing to create a lead and apply trial' do
                before do
                  expect_next_instance_of(Groups::CreateService) do |service|
                    expect(service).to receive(:execute).and_return(group)
                  end
                  expect_next_instance_of(GitlabSubscriptions::CreateLeadService) do |service|
                    expect(service).to receive(:execute).with(trial_params).and_return(success: false)
                  end
                end

                it { is_expected.to render_template(:new) }
              end
            end

            context 'when user chooses no trial' do
              let_it_be(:trial_form_params) { { trial: 'false' } }

              it 'calls the record user trial_during_signup experiment' do
                expect_next_instance_of(Groups::CreateService) do |service|
                  expect(service).to receive(:execute).and_return(group)
                end

                expect(controller).to receive(:record_experiment_user).with(:trial_during_signup, trial_chosen: false, namespace_id: group.id)

                expect(subject).to redirect_to(new_users_sign_up_project_path(namespace_id: group.id, trial: false))
              end

              it 'does not call trial_during_signup experiment methods' do
                expect(controller).not_to receive(:create_lead)
                expect(controller).not_to receive(:apply_trial)

                subject
              end

              context 'with registrations_group_invite experiment' do
                it 'tracks experiment as expected', :experiment do
                  expect_next_instance_of(Groups::CreateService) do |service|
                    expect(service).to receive(:execute).and_return(group)
                  end

                  expect(experiment(:registrations_group_invite))
                    .to track(:created, { property: group.id.to_s })
                          .on_next_instance
                          .with_context(actor: user)

                  subject
                end

                context 'when registrations_group_invite invite_page path is taken' do
                  before do
                    stub_experiments(registrations_group_invite: :invite_page)
                  end

                  it { is_expected.to redirect_to(new_users_sign_up_group_invite_path(group_id: user.groups.last.id, trial: false)) }
                end

                context 'when registrations_group_invite experiment control path is taken' do
                  before do
                    stub_experiments(registrations_group_invite: :control)
                  end

                  it { is_expected.to redirect_to(new_users_sign_up_project_path(namespace_id: user.groups.last.id, trial: false)) }
                end
              end
            end
          end

          context 'when not in experiment group for trial_during_signup' do
            before do
              allow(controller).to receive(:experiment_enabled?).with(:trial_during_signup).and_return(false)
            end

            it 'tracks experiment as expected', :experiment do
              expect_next_instance_of(Groups::CreateService) do |service|
                expect(service).to receive(:execute).and_return(group)
              end
              expect(experiment(:registrations_group_invite))
                .to track(:created, { property: group.id.to_s })
                      .on_next_instance
                      .with_context(actor: user)

              subject
            end

            context 'when registrations_group_invite invite_page path is taken' do
              before do
                stub_experiments(registrations_group_invite: :invite_page)
              end

              it { is_expected.to redirect_to(new_users_sign_up_group_invite_path(group_id: user.groups.last.id, trial: false)) }
            end

            context 'when registrations_group_invite experiment control path is taken' do
              before do
                stub_experiments(registrations_group_invite: :control)
              end

              it { is_expected.to redirect_to(new_users_sign_up_project_path(namespace_id: user.groups.last.id, trial: false)) }

              it_behaves_like GroupInviteMembers
            end
          end
        end
      end

      context 'when the group cannot be created' do
        let(:group_params) { { name: '', path: '' } }

        it 'does not create a group', :aggregate_failures do
          expect { subject }.not_to change { Group.count }
          expect(assigns(:group).errors).not_to be_blank
        end

        it 'does not call call the successful flow' do
          expect(controller).not_to receive(:create_successful_flow)

          subject
        end

        it { is_expected.to have_gitlab_http_status(:ok) }
        it { is_expected.to render_template(:new) }
      end
    end
  end
end
