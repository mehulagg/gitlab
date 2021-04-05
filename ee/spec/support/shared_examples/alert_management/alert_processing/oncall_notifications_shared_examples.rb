# frozen_string_literal: true

# This shared_example requires the following variables:
# - `project`, the project receiving an alert notification
# - `users`, the users expected to receive emails
# - `fingerprint`, unique identifier for the alert
RSpec.shared_examples 'oncall users are correctly notified of firing alert' do
  it_behaves_like 'sends alert notification emails for on-call users if enabled'

  context 'when alert with the same fingerprint already exists' do
    let(:gitlab_fingerprint) { Digest::SHA1.hexdigest(fingerprint) }
    let!(:alert) { create(:alert_management_alert, status, project: project, fingerprint: gitlab_fingerprint) }

    it_behaves_like 'sends alert notification emails for on-call users if enabled' do
      let(:status) { :triggered }
    end

    it_behaves_like 'does not send alert notification emails' do
      let(:status) { :acknowledged }
    end

    it_behaves_like 'sends alert notification emails for on-call users if enabled' do
      let(:status) { :resolved }
    end

    it_behaves_like 'does not send alert notification emails' do
      let(:status) { :ignored }
    end
  end
end

# This shared_example requires the following variables:
# - `project`, the project receiving an alert notification
# - `users`, the users expected to receive emails
# - `fingerprint`, unique identifier for the alert
RSpec.shared_examples 'oncall users are correctly notified of recovery alert' do
  it_behaves_like 'sends alert notification emails for on-call users if enabled'

  context 'when alert with the same fingerprint already exists' do
    let(:gitlab_fingerprint) { Digest::SHA1.hexdigest(fingerprint) }
    let!(:alert) { create(:alert_management_alert, status, project: project, fingerprint: gitlab_fingerprint) }

    ::AlertManagement::Alert.status_names.each do |status|
      it_behaves_like 'sends alert notification emails for on-call users if enabled' do
        let(:status) { status }
      end
    end
  end
end

# This shared_example requires the following variables:
# - `users`, the users expected to receive emails
# - `fingerprint`, unique identifier for the alert
RSpec.shared_examples 'sends alert notification emails for on-call users if enabled' do
  it_behaves_like 'does not send alert notification emails'

  context 'with feature enabled' do
    let(:notification_async) { double(NotificationService::Async) }
    let(:gitlab_fingerprint) { Digest::SHA1.hexdigest(fingerprint) }
    let(:current_user) { users }

    before do
      stub_licensed_features(oncall_schedules: project)
    end

    it_behaves_like 'tracks count of unique users sent an on-call notification'

    specify do
      allow(NotificationService).to receive_message_chain(:new, :async).and_return(notification_async)
      expect(notification_async).to receive(:notify_oncall_users_of_alert).with(
        users,
        having_attributes(class: AlertManagement::Alert, fingerprint: gitlab_fingerprint)
      )

      subject
    end
  end
end

RSpec.shared_examples 'tracks count of unique users sent an on-call notification' do
  let(:counter) do
    {
      event_names: 'incident_management_oncall_notification_sent',
      start_date: 1.week.ago,
      end_date: 1.week.from_now
    }
  end

  specify do
    expect { subject }.to change { Gitlab::UsageDataCounters::HLLRedisCounter.unique_events(**counter) }.by 1
  end
end
