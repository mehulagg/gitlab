# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dast::SiteProfileSecretVariables::FindOrCreateService do
  let_it_be(:project) { create(:project) }
  let_it_be(:dast_profile) { create(:dast_profile, project: project) }
  let_it_be(:developer) { create(:user, developer_projects: [project] ) }

  let_it_be(:default_params) do
    {
      dast_site_profile: dast_profile.dast_site_profile,
      key: 'DAST_PASSWORD_BASE64',
      raw_value: SecureRandom.hex
    }
  end

  let(:params) { default_params }

  subject { described_class.new(container: project, current_user: developer, params: params).execute }

  describe 'execute' do
    context 'when on demand scan licensed feature is not available' do
      it 'communicates failure' do
        stub_licensed_features(security_on_demand_scans: false)

        aggregate_failures do
          expect(subject.status).to eq(:error)
          expect(subject.message).to eq('Insufficient permissions')
        end
      end
    end

    context 'when the feature is enabled' do
      before do
        stub_licensed_features(security_on_demand_scans: true)
      end

      it 'communicates success' do
        expect(subject.status).to eq(:success)
      end

      it 'creates a dast_site_profile_secret_variable' do
        expect { subject }.to change { Dast::SiteProfileSecretVariable.count }.by(1)
      end

      context 'when a param is missing' do
        let(:params) { default_params.except(:key) }

        it 'communicates failure', :aggregate_failures do
          expect(subject.status).to eq(:error)
          expect(subject.message).to eq('Key param missing')
        end
      end
    end
  end
end
