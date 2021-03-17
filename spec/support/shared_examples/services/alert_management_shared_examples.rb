# frozen_string_literal: true

RSpec.shared_examples 'creates an alert management alert' do
  it { is_expected.to be_success }

  it 'creates AlertManagement::Alert' do
    expect(Gitlab::AppLogger).not_to receive(:warn)

    expect { subject }.to change(AlertManagement::Alert, :count).by(1)
  end

  it 'executes the alert service hooks' do
    expect_next_instance_of(AlertManagement::Alert) do |alert|
      expect(alert).to receive(:execute_services)
    end

    subject
  end

  context 'and fails to save' do
    let(:errors) { double(messages: { hosts: ['hosts array is over 255 chars'] })}

    before do
      allow(service).to receive(:alert).and_call_original
      allow(service).to receive_message_chain(:alert, :save).and_return(false)
      allow(service).to receive_message_chain(:alert, :errors).and_return(errors)
    end

    it_behaves_like 'alerts service responds with an error', :bad_request

    it 'writes a warning to the log' do
      expect(Gitlab::AppLogger).to receive(:warn).with(
        message: "Unable to create AlertManagement::Alert from #{source}",
        project_id: project.id,
        alert_errors: { hosts: ['hosts array is over 255 chars'] }
      )

      subject
    end
  end
end

# This shared_example requires the following variables:
# - last_alert_attributes, last created alert
# - project, project that alert created
# - payload_raw, hash representation of payload
# - environment, project's environment
# - fingerprint, fingerprint hash
RSpec.shared_examples 'assigns the alert properties' do |overrides = {}|
  it 'ensures that created alert has all data properly assigned' do
    subject

    expect(last_alert_attributes).to match({
      project_id: project.id,
      title: payload_raw.fetch(:title),
      started_at: Time.zone.parse(payload_raw.fetch(:start_time)),
      severity: payload_raw.fetch(:severity, nil),
      status: AlertManagement::Alert.status_value(:triggered),
      events: 1,
      domain: domain,
      hosts: payload_raw.fetch(:hosts, nil),
      payload: payload_raw.with_indifferent_access,
      issue_id: nil,
      description: payload_raw.fetch(:description, nil),
      monitoring_tool: payload_raw.fetch(:monitoring_tool, nil),
      service: payload_raw.fetch(:service, nil),
      fingerprint: Digest::SHA1.hexdigest(fingerprint),
      environment_id: environment.id,
      ended_at: nil,
      prometheus_alert_id: nil
    }.merge(overrides).with_indifferent_access)
  end
end

RSpec.shared_examples 'does not an create alert management alert' do
  it 'does not create alert' do
    expect { subject }.not_to change(AlertManagement::Alert, :count)
  end
end

RSpec.shared_examples 'adds an alert management alert event' do
  it { is_expected.to be_success }

  it 'does not create an alert' do
    expect { subject }.not_to change(AlertManagement::Alert, :count)
  end

  it 'increases alert events count' do
    expect { subject }.to change { alert.reload.events }.by(1)
  end

  it 'does not executes the alert service hooks' do
    expect(alert).not_to receive(:execute_services)

    subject
  end
end

RSpec.shared_examples 'does not add an alert management alert event' do
  specify do
    expect { subject }.not_to change { alert.reload.events }
  end
end

RSpec.shared_examples 'resolves an existing alert management alert' do
  it 'sets the end time and status' do
    expect(Gitlab::AppLogger).not_to receive(:warn)

    expect { subject }
      .to change { alert.reload.resolved? }.to(true)
      .and change { alert.ended_at.present? }.to(true)

    expect(subject).to be_success
  end
end

RSpec.shared_examples 'does not change the alert end time' do
  specify do
    expect { subject }.not_to change { alert.reload.ended_at }
  end
end

RSpec.shared_examples 'writes a warning to the log for a failed alert status update' do
  before do
    allow(service).to receive(:alert).and_call_original
    allow(service).to receive_message_chain(:alert, :resolve).and_return(false)
  end

  specify do
    expect(Gitlab::AppLogger).to receive(:warn).with(
      message: 'Unable to update AlertManagement::Alert status to resolved',
      project_id: project.id,
      alert_id: alert ? alert.id : (last_alert_id + 1)
    )

    # Failure to resolve a recovery alert is not critical failure
    expect(subject).to be_success
  end

  private

  def last_alert_id
    AlertManagement::Alert.connection
      .select_value("SELECT nextval('#{AlertManagement::Alert.sequence_name}')")
  end
end

RSpec.shared_context 'incident management settings enabled' do
  let(:auto_close_incident) { true }
  let(:create_issue) { true }
  let(:send_email) { true }

  let(:incident_management_setting) do
    double(
      auto_close_incident?: auto_close_incident,
      create_issue?: create_issue,
      send_email?: send_email
    )
  end

  before do
    allow(ProjectServiceWorker).to receive(:perform_async)
    allow(service)
      .to receive(:incident_management_setting)
      .and_return(incident_management_setting)
  end
end

# Potentially requires `source` to be defined
RSpec.shared_examples 'creates expected system notes' do |*notes|
  let(:expected_notes) do
    {
      new_alert: source,
      recovery_alert: source,
      resolve_alert: 'Resolved',
      resolve_issue: 'automatically closed',
    }.slice(*notes)
  end
  let(:expected_note_count) { expected_notes.length }
  let(:new_notes) { Note.last(expected_note_count).pluck(:note) }

  it "for #{notes.join(', ')}" do
    expect { subject }.to change(Note, :count).by(expected_note_count)

    expected_notes.each_value.with_index do |value, index|
      expect(new_notes[index]).to include(value)
    end
  end
end

RSpec.shared_examples 'does not create a system note for alert' do
  specify do
    expect { subject }.not_to change(Note, :count)
  end
end

# Expects usage of 'incident settings enabled' context
RSpec.shared_examples 'processes incident issues' do |with_issue: false|
  before do
    allow_any_instance_of(AlertManagement::Alert).to receive(:execute_services)
  end

  specify do
    expect(IncidentManagement::ProcessAlertWorker)
      .to receive(:perform_async)
      .with(nil, nil, kind_of(Integer))
      .once

    Sidekiq::Testing.inline! do
      expect(subject).to be_success
    end
  end

  context 'with issue', if: with_issue do
    before do
      alert.update!(issue: create(:issue, project: project))
    end

    it_behaves_like 'does not process incident issues'
  end

  context 'with incident setting disabled' do
    let(:create_issue) { false }

    it_behaves_like 'does not process incident issues'
  end
end

RSpec.shared_examples 'does not process incident issues' do
  specify do
    expect(IncidentManagement::ProcessAlertWorker).not_to receive(:perform_async)

    subject
  end
end

# Expects usage of 'incident settings enabled' context
RSpec.shared_examples 'sends alert notification emails' do
  let(:notification_service) { spy }

  specify do
    expect(NotificationService)
      .to receive(:new)
      .and_return(notification_service)

    expect(notification_service)
      .to receive_message_chain(:async, :prometheus_alerts_fired)

    subject
  end

  context 'with email setting disabled' do
    let(:send_email) { false }

    it_behaves_like 'does not send alert notification emails'
  end
end

RSpec.shared_examples 'does not send alert notification emails' do
  specify do
    expect(NotificationService).not_to receive(:new)

    subject
  end
end

# Expects usage of 'incident settings enabled' context
RSpec.shared_examples 'closes related issue' do
  context 'with issue' do
    before do
      alert.update!(issue: create(:issue, project: project))
    end

    it { expect { subject }.to change { alert.issue.reload.closed? }.from(false).to(true) }
    it { expect { subject }.to change(ResourceStateEvent, :count).by(1) }
  end

  context 'without issue' do
    it { expect { subject }.not_to change { alert.reload.issue } }
    it { expect { subject }.not_to change(ResourceStateEvent, :count) }
  end

  context 'with incident setting disabled' do
    let(:auto_close_incident) { false }

    it_behaves_like 'does not close related issue'
  end
end

RSpec.shared_examples 'does not close related issue' do
  it { expect { subject }.not_to change { alert.reload.issue&.state } }
  it { expect { subject }.not_to change(ResourceStateEvent, :count) }
end

RSpec.shared_examples 'alerts service responds with an error' do |http_status|
  it_behaves_like 'does not an create alert management alert'
  it_behaves_like 'does not create a system note for alert'
  it_behaves_like 'does not process incident issues'
  it_behaves_like 'does not send alert notification emails'

  specify do
    expect(subject).to be_error
    expect(subject.http_status).to eq(http_status)
  end
end

# Example with common combination of behavior
RSpec.shared_examples 'never-before-seen alert' do
  it_behaves_like 'creates an alert management alert'
  it_behaves_like 'creates expected system notes', :new_alert
  it_behaves_like 'processes incident issues'
  it_behaves_like 'sends alert notification emails'
end

RSpec.shared_examples 'processes new firing alert' do
  include_examples 'never-before-seen alert'

  context 'for an existing alert' do
    let(:gitlab_fingerprint) { Digest::SHA1.hexdigest(fingerprint) }
    let!(:alert) { create(:alert_management_alert, status, project: project, fingerprint: gitlab_fingerprint) }

    context 'which is triggered' do
      let(:status) { :triggered }

      it_behaves_like 'adds an alert management alert event'
      it_behaves_like 'sends alert notification emails'
      it_behaves_like 'processes incident issues', with_issue: true

      it_behaves_like 'does not an create alert management alert'
      it_behaves_like 'does not create a system note for alert'

      context 'with an existing resolved alert as well' do
        let!(:resolved_alert) { create(:alert_management_alert, :resolved, project: project, fingerprint: gitlab_fingerprint) }

        it_behaves_like 'adds an alert management alert event'
        it_behaves_like 'sends alert notification emails'
        it_behaves_like 'processes incident issues', with_issue: true

        it_behaves_like 'does not an create alert management alert'
        it_behaves_like 'does not create a system note for alert'
      end
    end

    context 'which is acknowledged' do
      let(:status) { :acknowledged }

      it_behaves_like 'adds an alert management alert event'
      it_behaves_like 'processes incident issues', with_issue: true

      it_behaves_like 'does not an create alert management alert'
      it_behaves_like 'does not create a system note for alert'
      it_behaves_like 'does not send alert notification emails'
    end

    context 'which is ignored' do
      let(:status) { :ignored }

      it_behaves_like 'adds an alert management alert event'
      it_behaves_like 'processes incident issues', with_issue: true

      it_behaves_like 'does not an create alert management alert'
      it_behaves_like 'does not create a system note for alert'
      it_behaves_like 'does not send alert notification emails'
    end

    context 'which is resolved' do
      let(:status) { :resolved }

      include_examples 'never-before-seen alert'
    end
  end
end

RSpec.shared_examples 'processes recovery alert' do
  context 'seen for the first time' do
    let(:alert) { AlertManagement::Alert.last }

    it_behaves_like 'creates an alert management alert'
    it_behaves_like 'creates expected system notes', :new_alert, :recovery_alert, :resolve_alert
    it_behaves_like 'sends alert notification emails'

    it_behaves_like 'does not process incident issues'
    it_behaves_like 'writes a warning to the log for a failed alert status update'

    it 'resolves the alert' do
      subject

      expect(alert.ended_at).to be_present
      expect(alert.resolved?).to be(true)
    end
  end

  context 'for an existing alert' do
    let(:gitlab_fingerprint) { Digest::SHA1.hexdigest(fingerprint) }
    let!(:alert) { create(:alert_management_alert, status, project: project, fingerprint: gitlab_fingerprint, monitoring_tool: source) }

    context 'which is triggered' do
      let(:status) { :triggered }

      it_behaves_like 'resolves an existing alert management alert'
      it_behaves_like 'creates expected system notes', :recovery_alert, :resolve_alert
      it_behaves_like 'sends alert notification emails'
      it_behaves_like 'closes related issue'
      it_behaves_like 'writes a warning to the log for a failed alert status update'

      it_behaves_like 'does not an create alert management alert'
      it_behaves_like 'does not process incident issues'
      it_behaves_like 'does not add an alert management alert event'
    end

    context 'which is ignored' do
      let(:status) { :ignored }

      it_behaves_like 'resolves an existing alert management alert'
      it_behaves_like 'creates expected system notes', :recovery_alert, :resolve_alert
      it_behaves_like 'sends alert notification emails'
      it_behaves_like 'closes related issue'
      it_behaves_like 'writes a warning to the log for a failed alert status update'

      it_behaves_like 'does not an create alert management alert'
      it_behaves_like 'does not process incident issues'
      it_behaves_like 'does not add an alert management alert event'
    end

    context 'which is acknowledged' do
      let(:status) { :acknowledged }

      it_behaves_like 'resolves an existing alert management alert'
      it_behaves_like 'creates expected system notes', :recovery_alert, :resolve_alert
      it_behaves_like 'sends alert notification emails'
      it_behaves_like 'closes related issue'
      it_behaves_like 'writes a warning to the log for a failed alert status update'

      it_behaves_like 'does not an create alert management alert'
      it_behaves_like 'does not process incident issues'
      it_behaves_like 'does not add an alert management alert event'
    end

    context 'which is resolved' do
      let(:status) { :resolved }
      let(:new_alert) { AlertManagement::Alert.last }

      it_behaves_like 'creates an alert management alert'
      it_behaves_like 'creates expected system notes', :new_alert, :recovery_alert, :resolve_alert
      it_behaves_like 'sends alert notification emails'
      it_behaves_like 'does not process incident issues'
      it_behaves_like 'writes a warning to the log for a failed alert status update' do
        let(:alert) { nil } # Ensure the next alert id is used
      end

      it 'will resolve the new alert' do
        subject

        expect(new_alert.ended_at).to be_present
        expect(new_alert.resolved?).to be(true)
      end

      xit 'doesnt create a bunch of resolved alerts for self-resolving payloads if there have already been an occurrance' do
        it_behaves_like 'creates expected system notes', :recovery_alert
        it_behaves_like 'does not an create alert management alert'
        it_behaves_like 'does not send alert notification emails'
        it_behaves_like 'does not change the alert end time'
        it_behaves_like 'does not process incident issues'
        it_behaves_like 'does not add an alert management alert event'
      end
    end
  end
end
