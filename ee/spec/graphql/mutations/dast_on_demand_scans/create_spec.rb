# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::DastOnDemandScans::Create do
  let(:group) { create(:group) }
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository, group: group) }
  let(:full_path) { project.full_path }
  let(:dast_site_profile) { create(:dast_site_profile, project: project) }
  let(:dast_site_profile_id) { dast_site_profile.to_global_id }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  describe '#resolve' do
    subject do
      mutation.resolve(
        full_path: full_path,
        dast_site_profile_id: dast_site_profile_id
      )
    end

    context 'when on demand scan feature is enabled' do
      context 'when the project does not exist' do
        let(:full_path) { SecureRandom.hex }

        it 'raises an exception' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the user is not associated with the project' do
        it 'raises an exception' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the user is an owner' do
        it 'has no errors' do
          group.add_owner(user)

          expect(subject[:errors]).to be_empty
        end
      end

      context 'when the user is a maintainer' do
        it 'has no errors' do
          project.add_maintainer(user)

          expect(subject[:errors]).to be_empty
        end
      end

      context 'when the user is a developer' do
        it 'has no errors' do
          project.add_developer(user)

          expect(subject[:errors]).to be_empty
        end
      end

      context 'when the user is a reporter' do
        it 'raises an exception' do
          project.add_reporter(user)

          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the user is a guest' do
        it 'raises an exception' do
          project.add_guest(user)

          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the user can run a dast scan' do
        before do
          project.add_developer(user)
        end

        it 'returns a pipeline_url containing the correct path' do
          actual_url = subject[:pipeline_url]
          pipeline = Ci::Pipeline.last
          expected_url = Rails.application.routes.url_helpers.project_pipeline_url(
            project,
            pipeline
          )
          expect(actual_url).to eq(expected_url)
        end

        context 'when the dast_site_profile does not exist' do
          it 'raises an exception' do
            dast_site_profile.destroy!

            expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context 'when dast_scanner_profile_id is provided' do
          let(:dast_scanner_profile) { create(:dast_scanner_profile, project: project, target_timeout: 200, spider_timeout: 5000, use_ajax_spider: true, show_debug_messages: true, scan_type: 'active') }
          let(:dast_scanner_profile_id) { dast_scanner_profile.to_global_id }

          subject do
            mutation.resolve(
              full_path: full_path,
              dast_site_profile_id: dast_site_profile_id,
              dast_scanner_profile_id: dast_scanner_profile_id
            )
          end

          it 'has no errors' do
            group.add_owner(user)

            expect(subject[:errors]).to be_empty
          end

          it 'passes additional arguments to the underlying service object' do
            args = hash_including(
              spider_timeout: dast_scanner_profile.spider_timeout,
              target_timeout: dast_scanner_profile.target_timeout,
              use_ajax_spider: dast_scanner_profile.use_ajax_spider,
              show_debug_messages: dast_scanner_profile.show_debug_messages,
              full_scan_enabled: dast_scanner_profile.full_scan_enabled?
            )

            expect_any_instance_of(::Ci::RunDastScanService).to receive(:execute).with(args).and_call_original

            subject
          end
        end

        context 'when on demand scan licensed feature is not available' do
          it 'raises an exception' do
            stub_licensed_features(security_on_demand_scans: false)

            expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
          end
        end
      end
    end
  end
end
