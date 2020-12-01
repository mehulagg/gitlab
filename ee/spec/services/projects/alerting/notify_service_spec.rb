# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Alerting::NotifyService do
  let_it_be(:project, refind: true) { create(:project) }

  describe '#execute' do
    let(:service) { described_class.new(project, nil, payload) }
    let(:token) { integration.token }
    let(:payload) do
      {
        'title' => 'Test alert title'
      }
    end

    let(:integration) { create(:alert_management_http_integration, project: project) }

    subject { service.execute(token, integration) }

    context 'existing alert with same payload fingerprint' do
      let(:existing_alert) { create(:alert_management_alert, :from_payload, project: project, payload: payload) }

      before do
        stub_licensed_features(generic_alert_fingerprinting: fingerprinting_enabled)
        existing_alert # create existing alert after enabling flag
      end

      context 'generic fingerprinting license not enabled' do
        let(:fingerprinting_enabled) { false }

        it 'creates AlertManagement::Alert' do
          expect { subject }.to change(AlertManagement::Alert, :count)
        end

        it 'does not increment the existing alert count' do
          expect { subject }.not_to change { existing_alert.reload.events }
        end
      end

      context 'generic fingerprinting license enabled' do
        let(:fingerprinting_enabled) { true }

        it 'does not create AlertManagement::Alert' do
          expect { subject }.not_to change(AlertManagement::Alert, :count)
        end

        it 'increments the existing alert count' do
          expect { subject }.to change { existing_alert.reload.events }.from(1).to(2)
        end

        context 'end_time provided for subsequent alert' do
          let(:existing_alert) { create(:alert_management_alert, :from_payload, project: project, payload: payload.except('end_time')) }
          let(:payload) { { 'title' => 'title', 'end_time' => Time.current.change(usec: 0).iso8601 } }

          it 'does not create AlertManagement::Alert' do
            expect { subject }.not_to change(AlertManagement::Alert, :count)
          end

          it 'resolves the existing alert', :aggregate_failures do
            expect { subject }.to change { existing_alert.reload.resolved? }.from(false).to(true)
            expect(existing_alert.ended_at).to eq(payload['end_time'])
          end
        end
      end
    end
  end
end
