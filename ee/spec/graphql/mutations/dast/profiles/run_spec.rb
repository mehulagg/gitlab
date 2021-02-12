# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Dast::Profiles::Run do
  let_it_be_with_refind(:project) { create(:project, :repository) }

  let_it_be(:user) { create(:user) }
  let_it_be(:dast_profile) { create(:dast_profile, project: project) }

  let(:full_path) { project.full_path }
  let(:dast_profile_id) { dast_profile.to_global_id }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  specify { expect(described_class).to require_graphql_authorizations(:create_on_demand_dast_scan) }

  describe '#resolve' do
    subject do
      mutation.resolve(
        full_path: full_path,
        id: dast_profile_id
      )
    end

    context 'when the feature flag dast_saved_scans is disabled' do
      it 'raises an exception' do
        stub_licensed_features(security_on_demand_scans: true)
        stub_feature_flags(dast_saved_scans: false)

        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'when on demand scan licensed feature is not available' do
      it 'raises an exception' do
        stub_licensed_features(security_on_demand_scans: false)
        stub_feature_flags(dast_saved_scans: true)

        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'when the feature is enabled' do
      before do
        stub_licensed_features(security_on_demand_scans: true)
        stub_feature_flags(dast_saved_scans: true)
      end

      context 'when the project does not exist' do
        let(:full_path) { SecureRandom.hex }

        it 'raises an exception' do
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
          expected_url = Gitlab::Routing.url_helpers.project_pipeline_url(
            project,
            pipeline
          )

          expect(actual_url).to eq(expected_url)
        end

        context 'when the dast_profile does not exist' do
          let(:dast_profile_id) { Gitlab::GlobalId.build(nil, model_name: 'Dast::Profile', id: 'does_not_exist') }

          it 'communicates failure' do
            expect(subject[:errors]).to include('Profile not found for given parameters')
          end
        end

        context 'when scan_type=active' do
          let(:dast_scanner_profile) { create(:dast_scanner_profile, project: project, scan_type: 'active') }
          let(:dast_profile) { create(:dast_profile, project: project, dast_scanner_profile: dast_scanner_profile) }

          context 'when target is not validated' do
            it 'communicates failure' do
              expect(subject[:errors]).to include('Cannot run active scan against unvalidated target')
            end
          end

          context 'when target is validated' do
            it 'has no errors' do
              create(:dast_site_validation, state: :passed, dast_site_token: create(:dast_site_token, project: project, url: dast_profile.dast_site_profile.dast_site.url))

              expect(subject[:errors]).to be_empty
            end
          end
        end
      end
    end
  end
end
