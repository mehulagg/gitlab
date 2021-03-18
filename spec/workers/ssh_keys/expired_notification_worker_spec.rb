# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SshKeys::ExpiredNotificationWorker, type: :worker do
  subject(:worker) { described_class.new }

  describe '#perform' do
    let_it_be(:user) { create(:user) }

    context 'with expiring key today' do
      let_it_be(:expired_today) { create(:key, expires_at: Date.current, user: user) }

      it 'uses notification service to send email to the user' do
        expect_next_instance_of(NotificationService) do |notification_service|
          expect(notification_service).to receive(:ssh_key_expired).with(expired_today.user)
        end

        worker.perform
      end

      it 'updates notified column' do
        expect { worker.perform }.to change { expired_today.reload.on_expiry_notification_delivered }.from(false).to(true)
      end
    end

    context 'when key has expired in the past' do
      let_it_be(:expired_past) { create(:key, expires_at: Time.current - 1.day, user: user) }

      it 'user is not notified' do
        expect_next_instance_of(NotificationService) do |notification_service|
          expect(notification_service).not_to receive(:ssh_key_expired).with(expired_past.user)
        end

        worker.perform
      end

      it 'does not update notified column' do
        expect { worker.perform }.not_to change { expired_past.reload.on_expiry_notification_delivered }
      end
    end
  end
end
