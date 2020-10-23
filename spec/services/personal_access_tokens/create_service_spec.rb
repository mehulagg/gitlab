# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PersonalAccessTokens::CreateService do
  describe '#execute' do
    subject { service.execute }

    let(:user) { create(:user) }
    let(:params) { { name: 'Test token', impersonation: true, scopes: [:api], expires_at: Date.today + 1.month } }
    let(:service) { described_class.new(current_user: user, target_user: user, params: params) }
    let(:personal_access_token) { subject.payload[:personal_access_token] }

    context 'with valid params' do
      it 'creates personal access token record' do
        expect(Gitlab::AppLogger).to receive(:info).with(/User #{user.username} has created personal access token with id \d+ for user #{user.username}/)
        expect(subject.success?).to be true
        expect(personal_access_token.name).to eq(params[:name])
        expect(personal_access_token.impersonation).to eq(params[:impersonation])
        expect(personal_access_token.scopes).to eq(params[:scopes])
        expect(personal_access_token.expires_at).to eq(params[:expires_at])
        expect(personal_access_token.user).to eq(user)
      end
    end
  end
end
