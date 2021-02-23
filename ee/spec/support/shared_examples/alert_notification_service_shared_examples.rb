# frozen_string_literal: true

# Requires `users` and `fingerprint` to be defined
RSpec.shared_examples 'Alert Notification Service sends notification email to on-call users' do
  let(:notification_service) { instance_double(NotificationService) }

  it 'sends a notification' do
    expect(NotificationService).to receive(:new).and_return(notification_service)

    expect(notification_service)
      .to receive_message_chain(:async, :notify_oncall_users_of_alert)
      .with(
        users,
        having_attributes(class: AlertManagement::Alert, fingerprint: fingerprint)
      )

    expect(subject).to be_success
  end
end
