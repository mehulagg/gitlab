# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PersonalAccessTokens::CreateService do
  describe '#execute' do
    subject { service.execute }

    let(:user) { create(:user) }
    let(:params) { { name: 'Test token', impersonation: true, scopes: [:api], expires_at: Date.today + 1.month } }
    let(:service) { described_class.new(current_user: user, target_user: user, params: params) }

    it 'creates audit logs' do
      expect(EE::AuditEvents::PersonalAccessTokenAuditEventService).to receive(:new).with(user, nil, /Created personal access token with id \d+/).and_call_original
      subject
    end
  end
end
