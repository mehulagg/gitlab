# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Creating a DAST Scan' do
  include GraphqlHelpers

  let(:name) { SecureRandom.hex }
  let(:dast_site_profile) { create(:dast_site_profile, project: project) }
  let(:dast_scanner_profile) { create(:dast_scanner_profile, project: project) }

  let(:dast_scan) { DastScan.find_by(project: project, name: name) }

  let(:mutation_name) { :dast_scan_create }
  let(:mutation) do
    graphql_mutation(
      mutation_name,
      full_path: full_path,
      name: name,
      dast_site_profile_id: dast_site_profile.to_global_id.to_s,
      dast_scanner_profile_id: dast_scanner_profile.to_global_id.to_s,
      run_after_create: true
    )
  end

  it_behaves_like 'an on-demand scan mutation when user cannot run an on-demand scan'
  it_behaves_like 'an on-demand scan mutation when user can run an on-demand scan' do
    it 'returns the dast_site_profile id' do
      subject

      expect(mutation_response).to include('id' => global_id_of(dast_scan))
    end
  end
end
