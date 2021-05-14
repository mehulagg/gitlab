# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::NetworkAlertService do
  let_it_be(:project, reload: true) { create(:project, :repository) }
  let_it_be(:environment) { create(:environment, project: project) }

  let(:payload_raw) { build(:network_alert_payload) }
  let(:payload) { ActionController::Parameters.new(payload_raw).permit! }

  let(:service) { described_class.new(project, payload) }

  describe '#execute' do
    include_context 'incident management settings enabled'

    subject(:execute) { service.execute }

    shared_examples 'never-before-seen network alert' do
      it_behaves_like 'creates an alert management alert or errors'
      it_behaves_like 'creates expected system notes for alert', :new_alert
      it_behaves_like 'does not send alert notification emails'
      it_behaves_like 'does not process incident issues'

      it 'assigns the correct properties' do
        subject

        expect(last_alert_attributes).to match(a_hash_including({
          description: 'POLICY_DENIED',
          domain: 'threat_monitoring',
          ended_at: nil,
          environment_id: nil,
          events:  1,
          fingerprint: '23907c66f431ae66aad738553ccbd03e26f6838f',
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
    end

    shared_examples 'existing network alert' do
      it_behaves_like 'adds an alert management alert event'
      it_behaves_like 'does not create a system note for alert'
      it_behaves_like 'does not send alert notification emails'
      it_behaves_like 'does not process incident issues'
    end

    context 'with valid payload' do
      let(:source) { Gitlab::AlertManagement::Payload::MONITORING_TOOLS[:cilium] }
      let(:last_alert_attributes) do
        AlertManagement::Alert.last.attributes.except('id', 'iid', 'created_at', 'updated_at')
          .with_indifferent_access
      end

      it_behaves_like 'never-before-seen network alert'

      context 'for an existing alert with the same fingerprint' do
        let_it_be(:fingerprint_sha) { '23907c66f431ae66aad738553ccbd03e26f6838f' }

        context 'which is triggered' do
          let_it_be(:alert) do
            create(:alert_management_alert, :triggered, domain: :threat_monitoring, project: project, fingerprint: fingerprint_sha)
          end

          it_behaves_like 'existing network alert'

          context 'with an additional existing resolved alert' do
            before do
              create(
                :alert_management_alert,
                :resolved,
                domain: :threat_monitoring,
                project: project,
                fingerprint: fingerprint_sha
              )
            end

            it_behaves_like 'existing network alert'
          end
        end

        context 'which is resolved' do
          let_it_be(:alert) do
            create(:alert_management_alert, :resolved, domain: :threat_monitoring, project: project, fingerprint: fingerprint_sha)
          end

          it_behaves_like 'never-before-seen network alert'
        end
      end
    end

    context 'with overlong payload' do
      let(:deep_size_object) { instance_double(Gitlab::Utils::DeepSize, valid?: false) }

      before do
        allow(Gitlab::Utils::DeepSize).to receive(:new).and_return(deep_size_object)
      end

      it_behaves_like 'alerts service responds with an error and takes no actions', :bad_request
    end
  end
end
