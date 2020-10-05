# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastScannerProfiles::CreateService do
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository, creator: user) }
  let(:name) { FFaker::Company.catch_phrase }
  let(:target_timeout) { 60 }
  let(:spider_timeout) { 600 }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  describe '#execute' do
    subject do
      described_class.new(project, user).execute(
        name: name,
        target_timeout: target_timeout,
        spider_timeout: spider_timeout
      )
    end

    let(:status) { subject.status }
    let(:message) { subject.message }
    let(:errors) { subject.errors }
    let(:payload) { subject.payload }

    context 'when a user does not have access to a project' do
      let(:project) { create(:project) }

      it 'returns an error status' do
        expect(status).to eq(:error)
      end

      it 'populates message' do
        expect(message).to eq('Insufficient permissions')
      end
    end

    context 'when the user does not have permission to run a dast scan' do
      before do
        project.add_guest(user)
      end

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

      it 'creates a dast_scanner_profile' do
        expect { subject }.to change(DastScannerProfile, :count).by(1)
      end

      it 'returns a dast_scanner_profile payload' do
        expect(payload).to be_a(DastScannerProfile)
      end

      context 'when the dast_scanner_profile name exists' do
        before do
          create(:dast_scanner_profile, project: project, name: name)
        end

        it 'does not create a new dast_scanner_profile' do
          expect { subject }.not_to change(DastScannerProfile, :count)
        end

        it 'returns an error status' do
          expect(status).to eq(:error)
        end

        it 'populates message' do
          expect(message).to eq(['Name has already been taken'])
        end
      end

      context 'when on demand scan feature is disabled' do
        before do
          stub_feature_flags(security_on_demand_scans_feature_flag: false)
        end

        it 'returns an error status' do
          expect(status).to eq(:error)
        end

        it 'populates message' do
          expect(message).to eq('Insufficient permissions')
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
