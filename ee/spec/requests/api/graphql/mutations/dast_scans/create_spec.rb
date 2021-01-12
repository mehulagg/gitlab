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
      dast_site_profile_id: global_id_of(dast_site_profile),
      dast_scanner_profile_id: global_id_of(dast_scanner_profile),
      run_after_create: true
    )
  end

  it_behaves_like 'an on-demand scan mutation when user cannot run an on-demand scan'
  it_behaves_like 'an on-demand scan mutation when user can run an on-demand scan' do
    it 'returns dastScan.id' do
      subject

      expect(mutation_response.dig('dastScan', 'id')).to eq(global_id_of(dast_scan))
    end

    it 'returns dastScan.editPath' do
      subject

      expect(mutation_response.dig('dastScan', 'editPath')).to eq(edit_project_on_demand_scan_path(project, dast_scan))
    end

    it 'returns a non-empty pipelineUrl' do
      subject

      expect(mutation_response['pipelineUrl']).not_to be_blank
    end
  end
end
