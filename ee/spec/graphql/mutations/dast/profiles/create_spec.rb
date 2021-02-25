# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Dast::Profiles::Create do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:developer) { create(:user, developer_projects: [project] ) }
  let_it_be(:dast_site_profile) { create(:dast_site_profile, project: project) }
  let_it_be(:dast_scanner_profile) { create(:dast_scanner_profile, project: project) }

  let(:name) { SecureRandom.hex }
  let(:description) { SecureRandom.hex }
  let(:run_after_create) { false }

  let(:dast_profile) { Dast::Profile.find_by(project: project, name: name) }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: developer }, field: nil) }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  specify { expect(described_class).to require_graphql_authorizations(:create_on_demand_dast_scan) }

  describe '#resolve' do
    subject do
      mutation.resolve(
        full_path: project.full_path,
        name: name,
        description: description,
        branch_name: 'orphaned-branch',
        dast_site_profile_id: dast_site_profile.to_global_id.to_s,
        dast_scanner_profile_id: dast_scanner_profile.to_global_id.to_s,
        run_after_create: run_after_create
      )
    end

    context 'when the feature is licensed' do
      context 'when the feature is enabled' do
        it 'raises an exception' do
          stub_feature_flags(dast_saved_scans: false)

          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the user can run a dast scan' do
        it 'returns the dast_profile' do
          expect(subject[:dast_profile]).to eq(dast_profile)
        end

        context 'when run_after_create=true' do
          let(:run_after_create) { true }

          it 'returns the pipeline_url' do
            actual_url = subject[:pipeline_url]
            pipeline = Ci::Pipeline.find_by(
              project: project,
              sha: project.repository.commit.sha,
              source: :ondemand_dast_scan,
              config_source: :parameter_source
            )
            expected_url = Rails.application.routes.url_helpers.project_pipeline_url(
              project,
              pipeline
            )
            expect(actual_url).to eq(expected_url)
          end
        end

        context "when branch_name='orphaned_branch'" do
          context 'when the feature flag dast_branch_selection is disabled' do
            it 'does not set the branch_name' do
              stub_feature_flags(dast_branch_selection: false)

              expect(subject[:dast_profile].branch_name).to be_nil
            end
          end

          context 'when the feature flag dast_branch_selection is enabled' do
            it 'sets the branch_name' do
              expect(subject[:dast_profile].branch_name).to eq('orphaned-branch')
            end
          end
        end
      end
    end
  end
end
