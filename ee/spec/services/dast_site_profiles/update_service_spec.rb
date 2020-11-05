# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteProfiles::UpdateService do
  let(:project) { dast_site_profile.project }
  let(:user) { create(:user) }
  let(:dast_site_profile) { create(:dast_site_profile) }

  let(:new_profile_name) { SecureRandom.hex }
  let(:new_target_url) { generate(:url) }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  describe '#execute' do
    subject do
      described_class.new(project, user).execute(
        id: dast_site_profile.id,
        profile_name: new_profile_name,
        target_url: new_target_url
      )
    end

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

      it 'updates the dast_site_profile' do
        updated_dast_site_profile = payload.reload

        aggregate_failures do
          expect(updated_dast_site_profile.name).to eq(new_profile_name)
          expect(updated_dast_site_profile.dast_site.url).to eq(new_target_url)
        end
      end

      it 'returns a dast_site_profile payload' do
        expect(payload).to be_a(DastSiteProfile)
      end

      context 'when the target url is localhost' do
        let(:new_target_url) { 'http://localhost:3000/hello-world' }

        it 'returns an error status' do
          expect(status).to eq(:error)
        end

        it 'populates errors' do
          expect(errors).to include('Url is blocked: Requests to localhost are not allowed')
        end
      end

      context 'when the dast_site_profile doesn\'t exist' do
        before do
          dast_site_profile.destroy!
        end

        it 'returns an error status' do
          expect(status).to eq(:error)
        end

        it 'populates message' do
          expect(message).to eq('DastSiteProfile not found')
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
