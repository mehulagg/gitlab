# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::BanService do
  let_it_be(:admin) { create(:admin) }
  let_it_be(:non_admin) { create(:user) }

  let(:user) { create(:user) }

  shared_examples 'does not update banned state' do
    it 'returns error result' do
      aggregate_failures 'error result' do
        expect(operation[:status]).to eq(:error)
        expect(operation[:message]).to match(/State cannot transition/)
      end
    end

    it "does not change the user's state" do
      expect { operation }.not_to change { user.state }
    end
  end

  context "when not an admin" do
    subject(:service) { described_class.new(non_admin) }

    context 'when attempting to ban a user' do
      let(:operation) { service.execute(user) }

      it 'returns error result' do
        expect(operation[:status]).to eq(:error)
        expect(operation[:message]).to match(/You are not allowed to ban a user/)
      end

      it "does not change the user's state" do
        expect { operation }.not_to change { user.state }
      end

      it "does not create a BannedUser" do
        expect { operation }.not_to change { Users::BannedUser.count }
        expect(user.banned_user).to be_nil
      end
    end
  end

  context "when admin", :enable_admin_mode do
    subject(:service) { described_class.new(admin) }

    describe '#execute' do
      let(:operation) { service.execute(user) }

      context 'when successful' do
        it "succcessfully bans and blocks the user", :aggregate_failures do
          expect(operation[:status]).to eq(:success)
          expect(user.state).to eq('banned')
          expect(user.blocked?).to be_truthy
        end

        it "creates a BannedUser" do
          expect { operation }.to change { Users::BannedUser.count }.by(1)
          expect(user.banned_user).not_to be_nil
        end

        it 'logs ban in application logs' do
          allow(Gitlab::AppLogger).to receive(:info)

          operation

          expect(Gitlab::AppLogger).to have_received(:info).with(message: "User banned", user: "#{user.username}", email: "#{user.email}", banned_by: "#{admin.username}", ip_address: "#{admin.current_sign_in_ip}")
        end
      end

      context 'when user is already banned' do
        before do
          user.ban
        end

        it_behaves_like "does not update banned state"
      end
    end
  end
end
