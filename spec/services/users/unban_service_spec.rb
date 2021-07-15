# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::UnbanService do
  let(:current_user) { create(:admin) }
  let(:user) { create(:user) }

  subject(:service) { described_class.new(current_user) }

  describe '#execute' do
    subject(:operation) { service.execute(user) }

    context 'when successful', :enable_admin_mode do
      before do
        user.ban!
      end

      it { is_expected.to eq(status: :success) }

      it 'unbans the user' do
        expect { operation }.to change { user.state }.from('banned').to('active')
      end

      it 'removes the BannedUser' do
        expect { operation }.to change { Users::BannedUser.count }.by(-1)
      end

      it 'logs unban in application logs' do
        allow(Gitlab::AppLogger).to receive(:info)

        operation

        expect(Gitlab::AppLogger).to have_received(:info).with(message: "User unbanned", user: "#{user.username}", email: "#{user.email}", banned_by: "#{current_user.username}", ip_address: "#{current_user.current_sign_in_ip}")
      end
    end

    context 'when failed' do
      context 'when user is already active', :enable_admin_mode do
        it 'returns state error message' do
          expect(operation[:status]).to eq(:error)
          expect(operation[:message]).to match(/State cannot transition/)
        end

        it 'does not unban the user' do
          expect { operation }.not_to change { Users::BannedUser.count }
        end
      end

      context 'when user is not an admin' do
        before do
          user.ban!
        end

        it 'returns permissions error message' do
          expect(operation[:status]).to eq(:error)
          expect(operation[:message]).to match(/You are not allowed to unban a user/)
        end

        it 'does not unban the user', :aggregate_failures do
          expect { operation }.not_to change { Users::BannedUser.count }
          expect(user.state).to eq('banned')
        end
      end
    end
  end
end
