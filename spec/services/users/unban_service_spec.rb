# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::UnbanService do
  let(:current_user) { create(:admin) }

  subject(:service) { described_class.new(current_user) }

  describe '#execute' do
    subject(:operation) { service.execute(user) }

    context 'when successful' do
      let(:user) { create(:user, :banned) }

      it { is_expected.to eq(status: :success) }

      it "unbans the user" do
        expect { operation }.to change { user.state }.to('active')
      end

      it "unblocks the user" do
        expect { operation }.to change { user.blocked? }.from(true).to(false)
      end

      it "unhides issues authored by the user" do
        issue = create(:issue, author: user, hidden: true)

        expect { operation }.to change { issue.reload.hidden? }.from(true).to(false)
      end

      it 'logs unban in application logs' do
        allow(Gitlab::AppLogger).to receive(:info)

        operation

        expect(Gitlab::AppLogger).to have_received(:info).with(message: "User unbanned", user: "#{user.username}", email: "#{user.email}", unbanned_by: "#{current_user.username}", ip_address: "#{current_user.current_sign_in_ip}")
      end
    end

    context 'when failed' do
      let(:user) { create(:user) }
      let(:issue) { create(:issue, author: user, hidden: true) }

      it 'returns error result' do
        aggregate_failures 'error result' do
          expect(operation[:status]).to eq(:error)
          expect(operation[:message]).to match(/State cannot transition/)
        end
      end

      it "does not change the user's state" do
        expect { operation }.not_to change { user.state }
      end

      it "does not unhide issues authored by the user" do
        expect { operation }.not_to change { issue.hidden? }
      end
    end
  end
end
