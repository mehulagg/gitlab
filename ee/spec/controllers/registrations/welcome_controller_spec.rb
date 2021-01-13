# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Registrations::WelcomeController do
  let_it_be(:user) { create(:user) }
  let_it_be(:another_user) { create(:user) }
  let_it_be(:project) { create(:project, creator: user) }

  describe '#trial_getting_started' do
    subject(:trial_getting_started) do
      get :trial_getting_started, params: { learn_gitlab_project_id: project.id }
    end

    context 'without a signed in user' do
      it { is_expected.to redirect_to new_user_session_path }
    end

    context 'with the creator user signed' do
      before do
        sign_in(user)
      end

      it 'sets the learn_gitlab_project and renders' do
        subject

        is_expected.to render_template(:trial_getting_started)
      end
    end

    context 'with any other user signed in except the creator' do
      before do
        sign_in(another_user)
      end

      it 'sets the learn_gitlab_project and renders' do
        subject

        is_expected.to have_gitlab_http_status(:not_found)
      end
    end
  end

  describe '#update' do
    let(:setup_for_company) { 'false' }
    let(:email_opted_in) { '0' }

    subject(:update) do
      patch :update, params: {
        user: {
          role: 'software_developer',
          setup_for_company: setup_for_company,
          email_opted_in: email_opted_in
        }
      }
    end

    context 'without a signed in user' do
      it { is_expected.to redirect_to new_user_registration_path }
    end

    context 'with a signed in user' do
      before do
        sign_in(user)
      end

      context 'email updates' do
        context 'when setup for company is false' do
          context 'when the user opted in' do
            let(:email_opted_in) { '1' }

            it 'sets the email_opted_in fields' do
              subject

              expect(controller.current_user.email_opted_in).to be_truthy
              expect(controller.current_user.email_opted_in_ip).to be_present
              expect(controller.current_user.email_opted_in_source).to eq('GitLab.com')
              expect(controller.current_user.email_opted_in_at).not_to be_nil
            end
          end

          context 'when user opted out' do
            let(:email_opted_in) { '0' }

            it 'does not set the rest of the email_opted_in fields' do
              subject

              expect(controller.current_user.email_opted_in).to be_falsey
              expect(controller.current_user.email_opted_in_ip).to be_blank
              expect(controller.current_user.email_opted_in_source).to be_blank
              expect(controller.current_user.email_opted_in_at).to be_nil
            end
          end
        end

        context 'when setup for company is true' do
          let(:setup_for_company) { 'true' }

          it 'sets email_opted_in fields' do
            subject

            expect(controller.current_user.email_opted_in).to be_truthy
            expect(controller.current_user.email_opted_in_ip).to be_present
            expect(controller.current_user.email_opted_in_source).to eq('GitLab.com')
            expect(controller.current_user.email_opted_in_at).not_to be_nil
          end
        end
      end

      describe 'redirection' do
        it { is_expected.to redirect_to dashboard_projects_path }

        context 'when part of the onboarding issues experiment' do
          before do
            stub_experiment_for_subject(onboarding_issues: true)
          end

          it { is_expected.to redirect_to new_users_sign_up_group_path }

          context 'when in subscription flow' do
            before do
              allow(controller.helpers).to receive(:in_subscription_flow?).and_return(true)
            end

            it { is_expected.not_to redirect_to new_users_sign_up_group_path }
          end

          context 'when in invitation flow' do
            before do
              allow(controller.helpers).to receive(:in_invitation_flow?).and_return(true)
            end

            it { is_expected.not_to redirect_to new_users_sign_up_group_path }
          end

          context 'when in trial flow' do
            before do
              allow(controller.helpers).to receive(:in_trial_flow?).and_return(true)
            end

            it { is_expected.not_to redirect_to new_users_sign_up_group_path }
          end
        end
      end
    end

    describe 'recording the user and tracking events for the onboarding issues experiment' do
      using RSpec::Parameterized::TableSyntax

      let(:on_gitlab_com) { false }
      let(:experiment_enabled) { false }
      let(:experiment_enabled_for_user) { false }
      let(:in_subscription_flow) { false }
      let(:in_invitation_flow) { false }
      let(:in_oauth_flow) { false }
      let(:in_trial_flow) { false }

      before do
        sign_in(user)
        allow(::Gitlab).to receive(:com?).and_return(on_gitlab_com)
        stub_experiment(onboarding_issues: experiment_enabled)
        stub_experiment_for_subject(onboarding_issues: experiment_enabled_for_user)
        allow(controller.helpers).to receive(:in_subscription_flow?).and_return(in_subscription_flow)
        allow(controller.helpers).to receive(:in_invitation_flow?).and_return(in_invitation_flow)
        allow(controller.helpers).to receive(:in_oauth_flow?).and_return(in_oauth_flow)
        allow(controller.helpers).to receive(:in_trial_flow?).and_return(in_trial_flow)
      end

      context 'when on GitLab.com' do
        let(:on_gitlab_com) { true }

        context 'and the onboarding issues experiment is enabled' do
          let(:experiment_enabled) { true }

          context 'and we’re not in the subscription, invitation, oauth, or trial flow' do
            where(:experiment_enabled_for_user, :group_type) do
              true  | :experimental
              false | :control
            end

            with_them do
              it 'adds the user to the experiments table with the correct group_type' do
                expect(::Experiment).to receive(:add_user).with(:onboarding_issues, group_type, user, {})

                subject
              end

              it 'tracks a signed_up event', :snowplow do
                subject

                expect_snowplow_event(
                  category: 'Growth::Conversion::Experiment::OnboardingIssues',
                  action: 'signed_up',
                  label: anything,
                  property: "#{group_type}_group"
                )
              end
            end
          end

          context 'but we’re in the subscription, invitation, oauth, or trial flow' do
            where(:in_subscription_flow, :in_invitation_flow, :in_oauth_flow, :in_trial_flow) do
              true  | false | false | false
              false | true  | false | false
              false | false | true  | false
              false | false | false | true
            end

            with_them do
              it 'does not add the user to the experiments table' do
                expect(::Experiment).not_to receive(:add_user)

                subject
              end

              it 'does not track a signed_up event', :snowplow do
                subject

                expect_no_snowplow_event
              end
            end
          end
        end
      end

      context 'when not on GitLab.com, regardless of whether or not the experiment is enabled' do
        where(experiment_enabled: [true, false])

        with_them do
          it 'does not add the user to the experiments table' do
            expect(::Experiment).not_to receive(:add_user)

            subject
          end

          it 'does not track a signed_up event', :snowplow do
            subject

            expect_no_snowplow_event
          end
        end
      end
    end
  end
end
