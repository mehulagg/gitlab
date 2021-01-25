# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::RejectService do
  let_it_be(:current_user) { create(:admin) }
  let(:user) { create(:user, :blocked_pending_approval) }

  subject(:execute) { described_class.new(current_user).execute(user) }

  describe '#execute' do
    context 'failures' do
      context 'when the executor user is not allowed to reject users' do
        let(:current_user) { create(:user) }

        it 'returns error result' do
          expect(subject[:status]).to eq(:error)
          expect(subject[:message]).to match(/You are not allowed to reject a user/)
        end
      end

      context 'when the executor user is an admin in admin mode', :enable_admin_mode do
        context 'when user is not in pending approval state' do
          let(:user) { create(:user, state: 'active') }

          it 'returns error result' do
            expect(subject[:status]).to eq(:error)
            expect(subject[:message])
              .to match(/This user does not have a pending request/)
          end
        end
      end
    end

    context 'success' do
      context 'when the executor user is an admin in admin mode', :enable_admin_mode do
        it 'deletes the user', :sidekiq_inline do
          subject

          expect(subject[:status]).to eq(:success)
          expect { User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'emails the user on rejection' do
          expect_next_instance_of(NotificationService) do |notification|
            allow(notification).to receive(:user_admin_rejection).with(user.name, user.notification_email)
          end

          subject
        end

        it 'logs rejection in application logs' do
          allow(Gitlab::AppLogger).to receive(:info)

          subject

          expect(Gitlab::AppLogger).to have_received(:info).with("USER INSTANCE REQUEST REJECTED: user: #{user.username}, email: #{user.email}, rejected_by: #{current_user.username}, ip_address=#{current_user.current_sign_in_ip}")
        end
      end
    end
  end
end
