# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Profiles::PersonalAccessTokensController do
  describe '#index' do
    context 'expired yet active personal access token' do
      subject { get :index }

      let!(:user) { create(:user) }
      let!(:expired_active_personal_access_token) { create(:personal_access_token, expires_at: 5.days.ago, user: user) }

      before do
        sign_in(user)
        stub_licensed_features(enforce_pat_expiration: licensed)
        stub_application_setting(enforce_pat_expiration: application_setting)
      end

      shared_examples 'does not include in list of active tokens' do
        it do
          subject

          expect(assigns(:active_personal_access_tokens)).not_to include(expired_active_personal_access_token)
        end
      end

      context 'when token expiry is enforced' do
        using RSpec::Parameterized::TableSyntax

        where(:licensed, :application_setting) do
          true  | true
          false | true
          false | false
        end

        with_them do
          it_behaves_like 'does not include in list of active tokens'
        end
      end

      context 'when token expiry is NOT enforced' do
        let(:licensed) { true }
        let(:application_setting) { false }

        it do
          subject

          expect(assigns(:active_personal_access_tokens)).to include(expired_active_personal_access_token)
        end
      end
    end
  end
end
