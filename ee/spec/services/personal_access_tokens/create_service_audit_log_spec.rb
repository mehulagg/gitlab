# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PersonalAccessTokens::CreateService do
  describe '#execute' do
    subject { service.execute }

    let(:params) { { name: 'Test token', impersonation: true, scopes: [:api], expires_at: Date.today + 1.month } }
    let(:service) { described_class.new(current_user: user, target_user: user, params: params) }

    context 'personal access tokens' do
      let(:user) { create(:user) }

      it 'creates audit logs' do
        expect(::AuditEventService)
          .to receive(:new)
          .with(user, user, action: :custom, custom_message: /Created personal access token with id \d+/, ip_address: nil)
          .and_call_original

        subject
      end
    end

    context 'project access tokens' do
      let_it_be(:user) { create(:user, :project_bot) }
      let_it_be(:project_access_token) { create(:personal_access_token, user: user) }

      it 'creates project access token audit logs' do
        expect(::AuditEventService)
          .to receive(:new)
          .with(user, user, action: :custom, custom_message: /Created project access token with id \d+/, ip_address: nil)
          .and_call_original

        subject
      end
    end
  end
end
