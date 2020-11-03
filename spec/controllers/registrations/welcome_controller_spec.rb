# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Registrations::WelcomeController do
  describe '#welcome' do
    subject(:show) { get :show }

    context 'without a signed in user' do
      it { is_expected.to redirect_to new_user_registration_path }
    end

    it 'renders the welcome layout' do
      sign_in(create(:user))

      expect(subject).to render_template(:show)
    end

    context '2FA is required from group' do
      before do
        user = create(:user, require_two_factor_authentication_from_group: true)
        sign_in(user)
      end

      it 'does not perform a redirect' do
        expect(subject).not_to redirect_to(profile_two_factor_auth_path)
      end
    end
  end

  describe '#update' do
    subject(:update) do
      patch :update, params: { user: { role: 'software_developer', setup_for_company: 'false' } }
    end

    context 'without a signed in user' do
      it { is_expected.to redirect_to new_user_registration_path }
    end

    context 'with a signed in user' do
      before do
        sign_in(create(:user))
      end

      it { is_expected.to redirect_to(dashboard_projects_path)}
    end
  end
end
