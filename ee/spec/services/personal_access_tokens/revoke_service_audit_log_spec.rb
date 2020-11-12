# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PersonalAccessTokens::RevokeService do
  describe '#execute' do
    subject { service.execute }

    let(:user) { create(:user) }
    let(:token) { create(:personal_access_token, user: user) }
    let(:service) { described_class.new(user, token: token) }

    it 'creates audit logs' do
      expect(::AuditEventService)
        .to receive(:new)
        .with(user, user, action: :custom, custom_message: "Revoked personal access token with id #{token.id}")
        .and_call_original

      subject
    end
  end
end
