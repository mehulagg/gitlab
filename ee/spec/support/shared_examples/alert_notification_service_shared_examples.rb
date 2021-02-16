# frozen_string_literal: true

RSpec.shared_examples 'Alert Notification Service sends notification email to on-call users' do
  let(:notification_service) { instance_double(NotificationService) }

  context 'with oncall schedules enabled' do
    before do
      stub_licensed_features(oncall_schedules: project)
    end

    it 'sends a notification' do
      expect(NotificationService).to receive(:new).and_return(notification_service)

      expect(notification_service)
        .to receive_message_chain(:async, :notify_oncall_users_of_alert)
        .with(*notification_args)

      expect(subject).to be_success
    end
  end

  context 'with oncall schedules disabled' do
    it 'does not notify the on-call users' do
      expect(NotificationService).not_to receive(:new)

      expect(subject).to be_success
    end
  end
end
