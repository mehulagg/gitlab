# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Profiles::PreferencesController do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'PATCH update' do
    subject { patch :update, params: { user: { group_view: group_view } }, format: :js }

    let(:group_view) { 'security_dashboard' }

    context 'when security dashboard feature enabled' do
      before do
        stub_licensed_features(security_dashboard: true)
      end

      context 'and valid group view choice is submitted' do
        it "changes the user's preferences" do
          expect { subject }.to change { user.reload.group_view_security_dashboard? }.from(false).to(true)
        end

        context 'and an invalid group view choice is submitted' do
          let(:group_view) { 'foo' }

          it 'sets the flash' do
            subject
            expect(flash[:alert]).to match(/Failed to save preferences/)
          end
        end
      end
    end

    context 'when security dashboard feature is disabled' do
      context 'when security dashboard feature enabled' do
        specify do
          expect { subject }.not_to change { user.reload.group_view_security_dashboard? }
        end
      end
    end
  end
end
