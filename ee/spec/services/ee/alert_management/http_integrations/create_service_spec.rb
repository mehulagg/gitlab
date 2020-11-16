# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::HttpIntegrations::CreateService do
  let_it_be(:user) { create(:user) }
  let_it_be_with_reload(:project) { create(:project) }
  let(:params) { { name: 'New HTTP Integration' } }

  let(:service) { described_class.new(project, user, params) }

  before do
    project.add_maintainer(user)

    stub_licensed_features(multiple_alert_http_integrations: true)
  end

  describe '#execute' do
    subject(:response) { service.execute }

    context 'when an integration already exists' do
      let_it_be(:existing_integration) { create(:alert_management_http_integration, project: project) }

      it 'successfully creates a new integration' do
        expect(response).to be_success

        integration = response.payload[:integration]
        expect(integration).to be_a(::AlertManagement::HttpIntegration)
        expect(integration.name).to eq('New HTTP Integration')
        expect(integration).not_to be_active
        expect(integration.token).to be_present
        expect(integration.endpoint_identifier).to be_present
      end
    end
  end
end
