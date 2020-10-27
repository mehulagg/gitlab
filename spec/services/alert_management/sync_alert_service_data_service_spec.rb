# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::SyncAlertServiceDataService do
  let_it_be(:alerts_service) { create(:alerts_service, :active) }

  describe '#execute' do
    subject { described_class.new(alerts_service).execute}

    context 'without http integration' do
      it 'returns a success' do
        expect(subject.success?).to eq(true)
      end
    end

    context 'existing legacy http integration' do
      let_it_be(:integration) { create(:alert_management_http_integration, :legacy, project: alerts_service.project) }

      it 'updates the integration' do
        expect { subject }
          .to change { integration.reload.encrypted_token }.to(alerts_service.data.encrypted_token)
          .and change { integration.encrypted_token_iv }.to(alerts_service.data.encrypted_token_iv)
      end
    end

    context 'existing other http integration' do
      let_it_be(:integration) { create(:alert_management_http_integration,  project: alerts_service.project) }

      it 'does not update the integration' do
        expect { subject }
          .not_to change { integration }
      end
    end
  end
end
