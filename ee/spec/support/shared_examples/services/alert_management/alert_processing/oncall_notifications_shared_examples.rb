# frozen_string_literal: true

# This shared_example requires the following variables:
# - `users`, users expected to receive on-call notifications
# - `gitlab_fingerprint`, SHA which is used to uniquely identify the alert
RSpec.shared_examples 'sends on-call notification if enabled' do
  context 'with on-call schedules enabled' do
    let(:alert) { having_attributes(class: AlertManagement::Alert, fingerprint: gitlab_fingerprint) }

    it_behaves_like 'sends on-call notification'

    context 'escalation policy features are disabled' do
      before do
        stub_licensed_features(oncall_schedules: true, escalation_policies: false)
        stub_feature_flags(escalation_policies_mvc: false)
      end

      it_behaves_like 'sends on-call notification'
    end
  end

  context 'with on-call schedules disabled' do
    before do
      stub_licensed_features(oncall_schedules: false)
    end

    it_behaves_like 'does not send on-call notification'
  end
end

RSpec.shared_examples 'sends on-call notification' do
  let(:notification_async) { double(NotificationService::Async) }

  specify do
    allow(NotificationService).to receive_message_chain(:new, :async).and_return(notification_async)
    expect(notification_async).to receive(:notify_oncall_users_of_alert).with(
      users,
      alert
    )

    subject
  end
end

RSpec.shared_examples 'does not send on-call notification' do
  specify do
    expect(NotificationService).not_to receive(:new)

    subject
  end
end
