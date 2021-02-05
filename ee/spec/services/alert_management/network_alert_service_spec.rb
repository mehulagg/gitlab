# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::NetworkAlertService do
  let_it_be(:project, reload: true) { create(:project, :repository) }
  let_it_be(:environment) { create(:environment, project: project) }

  describe '#execute' do
    let(:service) { described_class.new(project, payload) }
    let(:tool) { Gitlab::AlertManagement::Payload::MONITORING_TOOLS[:cilium] }
    let(:starts_at) { Time.current.change(usec: 0) }
    let(:ended_at) { nil }
    let(:fingerprint) { 'test' }
    let(:domain) { 'threat_monitoring' }

    let(:incident_management_setting) { double(auto_close_incident?: auto_close_enabled) }

    let(:auto_close_enabled) { true }

    before do
      allow(service).to receive(:incident_management_setting).and_return(
        incident_management_setting
      )
    end

    subject(:execute) { service.execute }

    context 'with minimal payload' do
      let(:payload_raw) do
        {}.with_indifferent_access
      end

      let(:payload) { ActionController::Parameters.new(payload_raw).permit! }

      it_behaves_like 'creates an alert management alert'
    end

    context 'with valid payload' do
      let(:payload_raw) { build(:network_alert_payload) }

      let(:payload) { ActionController::Parameters.new(payload_raw).permit! }

      let(:last_alert_attributes) do
        AlertManagement::Alert.last.attributes.except('id', 'iid', 'created_at', 'updated_at')
          .with_indifferent_access
      end

      it 'create alert and assigns properties' do
        subject

        expect(last_alert_attributes).to match(a_hash_including({
          description: 'POLICY_DENIED',
          domain: 'threat_monitoring',
          ended_at: nil,
          environment_id: nil,
          events:  1,
          fingerprint: 'a94a8fe5ccb19ba61c4c0873d391e987982fbbd3',
          hosts: [],
          issue_id: nil,
          monitoring_tool: 'Cilium',
          payload: payload_raw.with_indifferent_access,
          project_id: project.id,
          prometheus_alert_id:  nil,
          service: nil,
          severity:  'critical',
          title: 'Cilium Alert'
        }))
      end

      it 'creates a system note corresponding to alert creation' do
        expect { subject }.to change(Note, :count).by(1)
        expect(Note.last.note).to include('Cilium')
      end

      context 'when alert exists' do
        let!(:alert) do
          create(
            :alert_management_alert,
            project: project, domain: :threat_monitoring, fingerprint: Digest::SHA1.hexdigest(fingerprint)
          )
        end

        it_behaves_like 'does not an create alert management alert'
      end

      context 'existing alert with same fingerprint' do
        let(:fingerprint_sha) { Digest::SHA1.hexdigest(fingerprint) }
        let!(:alert) do
          create(:alert_management_alert, domain: :threat_monitoring, project: project, fingerprint: fingerprint_sha)
        end

        it_behaves_like 'adds an alert management alert event'

        context 'end time given' do
          let(:ended_at) { Time.current.change(nsec: 0) }

          context 'auto_close disabled' do
            let(:auto_close_enabled) { false }

            it 'does not resolve the alert' do
              expect { subject }.not_to change { alert.reload.status }
            end

            it 'does not set the ended at' do
              subject

              expect(alert.reload.ended_at).to be_nil
            end

            it_behaves_like 'does not an create alert management alert'
          end
        end

        context 'existing alert is resolved' do
          let!(:alert) do
            create(
              :alert_management_alert,
              :resolved,
              project: project, domain: :threat_monitoring, fingerprint: fingerprint_sha
            )
          end

          it_behaves_like 'creates an alert management alert'
        end

        context 'existing alert is ignored' do
          let!(:alert) do
            create(
              :alert_management_alert,
              :ignored,
              project: project, domain: :threat_monitoring, fingerprint: fingerprint_sha
            )
          end

          it_behaves_like 'adds an alert management alert event'
        end

        context 'two existing alerts, one resolved one open' do
          let!(:resolved_existing_alert) do
            create(
              :alert_management_alert,
              :resolved,
              project: project, fingerprint: fingerprint_sha
            )
          end

          let!(:alert) do
            create(:alert_management_alert, domain: :threat_monitoring, project: project, fingerprint: fingerprint_sha)
          end

          it_behaves_like 'adds an alert management alert event'
        end
      end
    end

    context 'with overlong payload' do
      let(:deep_size_object) { instance_double(Gitlab::Utils::DeepSize, valid?: false) }
      let(:payload) { ActionController::Parameters.new({}).permit! }

      before do
        allow(Gitlab::Utils::DeepSize).to receive(:new).and_return(deep_size_object)
      end

      it_behaves_like 'does not process incident issues due to error', http_status: :bad_request
      it_behaves_like 'does not an create alert management alert'
    end

    context 'error duing save' do
      let(:payload_raw) do
        {}.with_indifferent_access
      end

      let(:logger) { double(warn: {}) }
      let(:payload) { ActionController::Parameters.new(payload_raw).permit! }

      it 'logs warning' do
        expect_any_instance_of(AlertManagement::Alert).to receive(:save).and_return(false)
        expect_any_instance_of(described_class).to receive(:logger).and_return(logger)

        subject

        expect(logger).to have_received(:warn).with(
          hash_including(
            message: "Unable to create AlertManagement::Alert from #{tool}",
            project_id: project.id,
            alert_errors: {}
          )
        )
      end
    end
  end
end
