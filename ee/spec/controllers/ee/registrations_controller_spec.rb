# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RegistrationsController do
  describe '#create' do
    let_it_be(:base_user_params) { build_stubbed(:user).slice(:first_name, :last_name, :username, :password) }
    let_it_be(:new_user_email) { 'new@user.com' }
    let_it_be(:user_params) { { user: base_user_params.merge(email: new_user_email) } }

    subject { post :create, params: user_params }

    shared_examples 'blocked user by default' do
      it 'registers the user in blocked_pending_approval state' do
        subject
        created_user = User.find_by(email: new_user_email)

        expect(created_user).to be_present
        expect(created_user).to be_blocked_pending_approval
      end

      it 'does not log in the user after sign up' do
        subject

        expect(controller.current_user).to be_nil
      end

      it 'shows flash message after signing up' do
        subject

        expect(response).to redirect_to(new_user_session_path(anchor: 'login-pane'))
        expect(flash[:notice])
          .to match(/your account is awaiting approval from your GitLab administrator/)
      end
    end

    shared_examples 'active user by default' do
      it 'registers the user in active state' do
        subject
        created_user = User.find_by(email: new_user_email)

        expect(created_user).to be_present
        expect(created_user).to be_active
      end

      it 'does not show any flash message after signing up' do
        subject

        expect(flash[:notice]).to be_nil
      end
    end

    context 'when require admin approval setting is enabled' do
      before do
        stub_application_setting(require_admin_approval_after_user_signup: true)
      end

      it_behaves_like 'blocked user by default'
    end

    context 'when require admin approval setting is disabled' do
      before do
        stub_application_setting(require_admin_approval_after_user_signup: false)
      end

      it_behaves_like 'active user by default'

      context 'when user signup cap feature is enabled' do
        before do
          stub_application_setting(new_user_signups_cap: true)
        end

        it_behaves_like 'blocked user by default'
      end
    end

    context 'when user signup cap setting is enabled' do
      before do
        stub_application_setting(new_user_signups_cap: true)
      end

      it_behaves_like 'blocked user by default'

      context 'when feature flag is disabled' do
        before do
          stub_feature_flags(admin_new_user_signups_cap: false)
        end

        context 'when require admin approval setting is disabled' do
          before do
            stub_application_setting(require_admin_approval_after_user_signup: false)
          end

          it_behaves_like 'active user by default'
        end

        context 'when require admin approval setting is enabled' do
          before do
            stub_application_setting(require_admin_approval_after_user_signup: true)
          end

          it_behaves_like 'blocked user by default'
        end
      end
    end

    context 'when user signup cap setting is disabled' do
      before do
        stub_application_setting(admin_new_user_signups_cap: false)
      end

      context 'when require admin approval setting is disabled' do
        before do
          stub_application_setting(require_admin_approval_after_user_signup: false)
        end

        it_behaves_like 'active user by default'
      end

      context 'when require admin approval setting is enabled' do
        before do
          stub_application_setting(require_admin_approval_after_user_signup: true)
        end

        it_behaves_like 'blocked user by default'
      end
    end
  end
end
