# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::DastScans::Create do
  let(:project) { create(:project) }
  let(:developer) { create(:user, developer_projects: [project] ) }

  let(:full_path) { project.full_path }
  let(:name) { SecureRandom.hex }
  let(:description) { SecureRandom.hex }
  let(:dast_site_profile) { create(:dast_site_profile, project: project) }
  let(:dast_scanner_profile) { create(:dast_scanner_profile, project: project) }
  let(:run_after_create) { false }

  let(:dast_site) { DastSite.find_by(project: project, name: name) }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: developer }, field: nil) }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  specify { expect(described_class).to require_graphql_authorizations(:create_on_demand_dast_scan) }

  describe '#resolve' do
    subject do
      mutation.resolve(
        full_path: full_path,
        name: name,
        description: description,
        dast_site_profile_id: dast_site_profile.to_global_id.to_s,
        dast_scanner_profile_id: dast_scanner_profile.to_global_id.to_s,
        run_after_create: run_after_create
      )
    end

    context 'when on demand scan feature is enabled' do
      context 'when the project does not exist' do
        let(:full_path) { SecureRandom.hex }

        it 'raises an exception' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the user can run a dast scan' do
        it 'returns the dast_site' do
          subject

          expect(subject[:dast_scan]).to eq(dast_scan)
        end

        context 'when run_after_create=true' do
          let(:run_after_create) { true }

          it 'returns the pipeline_url' do
            subject

            expect(subject[:dast_scan]).to eq(dast_scan)
          end
        end
      end
    end
  end
end
