# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PersonalAccessTokens::CreateService do
  describe '#execute' do
    let_it_be(:user) { create(:user) }

    let(:params) { { name: 'admin-token', impersonation: true, scopes: [:api], expires_at: Date.today + 1.month } }

    context 'when non-admin user' do
      context 'when user creates their own token' do
        it 'creates AuditEvent with success message' do
          expect_to_log(user, user, /Created personal access token with id \d+/)

          described_class.new(current_user: user, target_user: user, params: params).execute
        end
      end

      context 'when user attempts to create a token for a different user' do
        let(:other_user) { create(:user) }

        it 'creates AuditEvent with failure message' do
          expect_to_log(user, other_user, 'Attempted to create personal access token but failed with message: Not permitted to create')

          described_class.new(current_user: user, target_user: other_user, params: params).execute
        end
      end
    end

    context 'when admin' do
      let(:admin) { create(:user, :admin) }

      it 'with admin mode enabled', :enable_admin_mode do
        expect_to_log(admin, user, /Created personal access token with id \d+/)

        described_class.new(current_user: admin, target_user: user, params: params).execute
      end

      context 'with admin mode disabled' do
        it 'creates audit logs with failure message' do
          expect_to_log(admin, user, 'Attempted to create personal access token but failed with message: Not permitted to create')

          described_class.new(current_user: admin, target_user: user, params: params).execute
        end
      end
    end
  end

  def expect_to_log(current_user, target_user, message)
    expect(::AuditEventService).to receive(:new)
      .with(current_user, target_user, action: :custom, custom_message: message, ip_address: nil)
      .and_call_original
  end
end
