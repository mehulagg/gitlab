# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteProfiles::CreateService do
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository, creator: user) }
  let(:name) { FFaker::Company.catch_phrase }
  let(:target_url) { generate(:url) }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  describe '#execute' do
    subject { described_class.new(project, user).execute(name: name, target_url: target_url) }

    let(:status) { subject.status }
    let(:message) { subject.message }
    let(:errors) { subject.errors }
    let(:payload) { subject.payload }

    context 'when a user does not have access to the project' do
      it 'returns an error status' do
        expect(status).to eq(:error)
      end

      it 'populates message' do
        expect(message).to eq('Insufficient permissions')
      end
    end

    context 'when the user can run a dast scan' do
      before do
        project.add_developer(user)
      end

      it 'returns a success status' do
        expect(status).to eq(:success)
      end

      it 'creates a dast_site_profile' do
        expect { subject }.to change(DastSiteProfile, :count).by(1)
      end

      it 'creates a dast_site' do
        expect { subject }.to change(DastSite, :count).by(1)
      end

      it 'returns a dast_site_profile payload' do
        expect(payload).to be_a(DastSiteProfile)
      end

      context 'when the dast_site already exists' do
        before do
          create(:dast_site, project: project, url: target_url)
        end

        it 'returns a success status' do
          expect(status).to eq(:success)
        end

        it 'does not create a new dast_site' do
          expect { subject }.not_to change(DastSite, :count)
        end
      end

      context 'when the target url is localhost' do
        let(:target_url) { 'http://localhost:3000/hello-world' }

        it 'returns an error status' do
          expect(status).to eq(:error)
        end

        it 'populates errors' do
          expect(errors).to include('Url is blocked: Requests to localhost are not allowed')
        end
      end

      context 'when on demand scan licensed feature is not available' do
        before do
          stub_licensed_features(security_on_demand_scans: false)
        end

        it 'returns an error status' do
          expect(status).to eq(:error)
        end

        it 'populates message' do
          expect(message).to eq('Insufficient permissions')
        end
      end
    end
  end
end
