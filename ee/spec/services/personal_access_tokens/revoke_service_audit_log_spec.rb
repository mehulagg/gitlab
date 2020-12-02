# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PersonalAccessTokens::RevokeService do
  describe '#execute' do
    subject { service.execute }


    let(:service) { described_class.new(user, token: token) }

    context 'personal access tokens' do
      let(:user) { create(:user) }
      let(:token) { create(:personal_access_token, user: user) }

      it 'creates audit logs' do
        expect(::AuditEventService)
          .to receive(:new)
          .with(user, user, action: :custom, custom_message: "Revoked personal access token with id #{token.id}")
          .and_call_original

        subject
      end
    end

    context 'project access tokens' do
      let_it_be(:user) { create(:user, :project_bot) }
      let_it_be(:token) { create(:personal_access_token, user: user) }

      it 'creates audit logs' do
        expect(::AuditEventService)
          .to receive(:new)
          .with(user, user, action: :custom, custom_message: "Revoked project access token with id #{token.id}")
          .and_call_original

        subject
      end
    end
  end
end
