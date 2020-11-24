# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::NetworkAlertService do
  let_it_be(:project, reload: true) { create(:project, :repository) }
  let_it_be(:environment) { create(:environment, project: project) }

  describe '#execute' do
    let(:service) { described_class.new(project, nil, payload) }
    let(:tool) { Gitlab::AlertManagement::Payload::MONITORING_TOOLS[:cilium] }
    let(:starts_at) { Time.current.change(usec: 0) }
    let(:ended_at) { nil }
    let(:fingerprint) { 'test' }

    let(:incident_management_setting) { double(auto_close_incident?: auto_close_enabled) }

    let(:auto_close_enabled) { true }

    before do
      allow(service).to receive(:incident_management_setting).and_return(
        incident_management_setting
      )
    end

    subject(:execute) { service.execute }

    context 'with valid payload' do
      let(:payload_raw) do
        {
          title: 'alert title',
          start_time: starts_at.rfc3339,
          end_time: ended_at&.rfc3339,
          severity: 'low',
          monitoring_tool: tool,
          service: 'GitLab Test Suite',
          description: 'Very detailed description',
          hosts: %w[1.1.1.1 2.2.2.2],
          fingerprint: fingerprint,
          gitlab_environment_name: environment.name
        }.with_indifferent_access
      end

      let(:payload) { ActionController::Parameters.new(payload_raw).permit! }

      let(:last_alert_attributes) do
        AlertManagement::Alert.last.attributes.except('id', 'iid', 'created_at', 'updated_at')
          .with_indifferent_access
      end

      it_behaves_like 'creates an alert management alert'
      it_behaves_like 'assigns the alert properties'

      it 'creates a system note corresponding to alert creation' do
        expect { subject }.to change(Note, :count).by(1)
        expect(Note.last.note).to include(payload_raw.fetch(:monitoring_tool))
      end

      context 'when alert exist' do
        let!(:alert) do
          create(
            :alert_management_alert,
            project: project, fingerprint: Digest::SHA1.hexdigest(fingerprint)
          )
        end

        it_behaves_like 'does not an create alert management alert'
      end

      context 'existing alert with same fingerprint' do
        let(:fingerprint_sha) { Digest::SHA1.hexdigest(fingerprint) }
        let!(:alert) do
          create(:alert_management_alert, project: project, fingerprint: fingerprint_sha)
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

          context 'auto_close_enabled setting enabled' do
            it 'resolves the alert and sets the end time', :aggregate_failures do
              subject
              alert.reload

              expect(alert.resolved?).to eq(true)
              expect(alert.ended_at).to eql(ended_at)
            end

            context 'related issue exists' do
              let(:alert) do
                create(
                  :alert_management_alert,
                  :with_issue,
                  project: project, fingerprint: fingerprint_sha
                )
              end

              let(:issue) { alert.issue }

              it { expect { subject }.to change { issue.reload.state }.from('opened').to('closed') }
              it { expect { subject }.to change(ResourceStateEvent, :count).by(1) }
            end

            context 'with issue enabled' do
              let(:issue_enabled) { true }

              it_behaves_like 'does not process incident issues'
            end
          end
        end

        context 'existing alert is resolved' do
          let!(:alert) do
            create(
              :alert_management_alert,
              :resolved,
              project: project, fingerprint: fingerprint_sha
            )
          end

          it_behaves_like 'creates an alert management alert'
          it_behaves_like 'assigns the alert properties'
        end

        context 'existing alert is ignored' do
          let!(:alert) do
            create(
              :alert_management_alert,
              :ignored,
              project: project, fingerprint: fingerprint_sha
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
            create(:alert_management_alert, project: project, fingerprint: fingerprint_sha)
          end

          it_behaves_like 'adds an alert management alert event'
        end
      end

      context 'end time given' do
        let(:ended_at) { Time.current }

        it_behaves_like 'creates an alert management alert'
        it_behaves_like 'assigns the alert properties'
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
  end
end
