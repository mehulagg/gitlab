# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastOnDemandScans::CreateService do
  let(:project) { create(:project, :repository) }
  let(:user) { create(:user) }
  let(:dast_site_profile) { create(:dast_site_profile, project: project) }
  let(:dast_scanner_profile) { create(:dast_scanner_profile, project: project) }

  subject do
    described_class.new(
      container: project,
      current_user: user,
      params: {
        dast_site_profile: dast_site_profile,
        dast_scanner_profile: dast_scanner_profile
      }
    ).execute
  end

  describe 'execute' do
    context 'when on demand scan licensed feature is not available' do
      context 'when the user cannot run an on demand scan' do
        it 'communicates failure' do
          stub_licensed_features(security_on_demand_scans: false)

          aggregate_failures do
            expect(subject.status).to eq(:error)
            expect(subject.message).to eq('Insufficient permissions')
          end
        end
      end
    end

    context 'when the feature is enabled' do
      before do
        stub_licensed_features(security_on_demand_scans: true)
      end

      context 'when user can run an on demand scan' do
        before do
          project.add_developer(user)
        end

        it 'communicates success' do
          expect(subject.status).to eq(:success)
        end

        it 'returns a pipeline and pipeline_url' do
          aggregate_failures do
            expect(subject.payload[:pipeline]).to be_a(Ci::Pipeline)
            expect(subject.payload[:pipeline_url]).to be_a(String)
          end
        end

        it 'delegates pipeline creation to Ci::RunDastScanService' do
          expected_params = {
            branch: 'master',
            full_scan_enabled: false,
            show_debug_messages: false,
            spider_timeout: nil,
            target_timeout: nil,
            target_url: dast_site_profile.dast_site.url,
            use_ajax_spider: false
          }

          service = double(Ci::RunDastScanService)
          response = ServiceResponse.error(message: 'Stubbed response')

          aggregate_failures do
            expect(Ci::RunDastScanService).to receive(:new).and_return(service)
            expect(service).to receive(:execute).with(expected_params).and_return(response)
          end

          subject
        end

        context 'when dast_scanner_profile is nil' do
          let(:dast_scanner_profile) { nil }

          it 'communicates success' do
            expect(subject.status).to eq(:success)
          end
        end

        context 'when target is not validated and an active scan is requested' do
          let(:dast_scanner_profile) { create(:dast_scanner_profile, project: project, scan_type: 'active') }

          it 'communicates failure' do
            aggregate_failures do
              expect(subject.status).to eq(:error)
              expect(subject.message).to eq('Cannot run active scan against unvalidated target')
            end
          end
        end
      end
    end
  end
end
