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
  end
end
