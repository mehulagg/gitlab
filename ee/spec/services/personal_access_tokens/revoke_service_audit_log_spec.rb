# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PersonalAccessTokens::RevokeService do
  describe '#execute' do
    subject { service.execute }

    let(:user) { create(:user) }
    let(:token) { create(:personal_access_token, user: user) }
    let(:service) { described_class.new(user, token: token) }

    it 'creates audit logs' do
      expect(EE::AuditEvents::PersonalAccessTokenAuditEventService).to receive(:new).with(user, nil, "Revoked personal access token with id #{token.id}").and_call_original
      subject
    end
  end
end
