# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PersonalAccessTokens::CreateService do
  describe '#execute' do
    let(:user) { create(:user) }
    let(:params) { { name: 'admin-token', impersonation: true, scopes: [:api], expires_at: Date.today + 1.month } }

    context 'when non-admin user' do
      context 'when user creates their own token' do
        it 'creates audit logs with success message' do
          expect(::AuditEventService)
          .to receive(:new)
          .with(user, user, action: :custom, custom_message: /Created personal access token with id \d+/, ip_address: nil)
          .and_call_original

          PersonalAccessTokens::CreateService.new(current_user: user, target_user: user, params: params).execute
        end
      end

      context 'when user attempts to create a token for a different user' do
        let(:other_user) { create(:user) }

        it 'creates audit logs with failure message' do
          expect(::AuditEventService)
            .to receive(:new)
            .with(user, other_user, action: :custom, custom_message: 'Attempted to create personal access token but failed with message: Not permitted to create', ip_address: nil)
            .and_call_original

          PersonalAccessTokens::CreateService.new(current_user: user, target_user: other_user, params: params).execute
        end
      end
    end

    context 'when admin' do
      let(:admin) { create(:user, :admin) }

      context 'with admin mode enabled', :enable_admin_mode do
        it 'creates audit logs with success message' do
          expect(::AuditEventService)
            .to receive(:new)
            .with(admin, user, action: :custom, custom_message: /Created personal access token with id \d+/, ip_address: nil)
            .and_call_original

          PersonalAccessTokens::CreateService.new(current_user: admin, target_user: user, params: params).execute
        end
      end

      context 'with admin mode disabled' do
        it 'creates audit logs with failure message' do
          expect(::AuditEventService)
            .to receive(:new)
            .with(admin, user, action: :custom, custom_message: 'Attempted to create personal access token but failed with message: Not permitted to create', ip_address: nil)
            .and_call_original

          PersonalAccessTokens::CreateService.new(current_user: admin, target_user: user, params: params).execute
        end
      end
    end
  end
end
