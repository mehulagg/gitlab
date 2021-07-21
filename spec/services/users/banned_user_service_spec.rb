# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::BannedUserService do
  let(:current_user) { create(:admin) }
  let(:user) { create(:user) }

  subject(:service) { described_class.new(current_user) }

  shared_examples 'user is in the wrong state' do
    it 'returns state error message' do
      expect(operation[:status]).to eq(:error)
      expect(operation[:message]).to match(/State cannot transition/)
    end
  end

  context 'ban', :aggregate_failures do
    subject(:operation) { service.execute(user, :ban) }

    context 'when successful', :enable_admin_mode do
      it { is_expected.to eq(status: :success) }

      it 'bans the user' do
        expect { operation }.to change { user.state }.from('active').to('banned')
      end

      it 'creates a BannedUser' do
        expect { operation }.to change { Users::BannedUser.count }.by(1)
        expect(Users::BannedUser.last.user_id).to eq(user.id)
      end

      it 'logs ban in application logs' do
        allow(Gitlab::AppLogger).to receive(:info)

        operation

        expect(Gitlab::AppLogger).to have_received(:info).with(message: "User ban", user: "#{user.username}", email: "#{user.email}", ban_by: "#{current_user.username}", ip_address: "#{current_user.current_sign_in_ip}")
      end
    end

    context 'when failed' do
      context 'when user is blocked', :enable_admin_mode do
        before do
          user.block!
        end

        it_behaves_like 'user is in the wrong state'

        it 'does not ban the user' do
          expect { operation }.not_to change { Users::BannedUser.count }
          expect(user.state).not_to eq('banned')
        end
      end

      context 'when user is not an admin' do
        it 'returns permissions error message' do
          expect(operation[:status]).to eq(:error)
          expect(operation[:message]).to match(/You are not allowed to ban a user/)
        end

        it 'does not ban the user', :aggregate_failures do
          expect { operation }.not_to change { Users::BannedUser.count }
          expect(user.state).to eq('active')
        end
      end
    end
  end

  context 'unban', :aggregate_failures do
    subject(:operation) { service.execute(user, :unban) }

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
        expect(user.reload.banned_user).to be_nil
      end

      it 'logs unban in application logs' do
        allow(Gitlab::AppLogger).to receive(:info)

        operation

        expect(Gitlab::AppLogger).to have_received(:info).with(message: "User unban", user: "#{user.username}", email: "#{user.email}", unban_by: "#{current_user.username}", ip_address: "#{current_user.current_sign_in_ip}")
      end
    end

    context 'when failed' do
      context 'when user is already active', :enable_admin_mode do
        it_behaves_like 'user is in the wrong state'

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

        it 'does not unban the user' do
          expect { operation }.not_to change { Users::BannedUser.count }
          expect(user.state).to eq('banned')
        end
      end
    end
  end
end
