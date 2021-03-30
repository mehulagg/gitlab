# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['Scan'] do
  let(:fields) { %i(name errors) }

  it { expect(described_class).to have_graphql_fields(fields) }
  it { expect(described_class).to require_graphql_authorizations(:read_scan) }

  describe 'serialized values' do
    let(:user) { create(:user) }
    let(:build) { create(:ee_ci_build, :dast, name: 'foo') }
    let(:response) { GitlabSchema.execute(query, context: context, variables: variables).as_json }
    let(:context) { { current_user: user } }
    let(:variables) { { projectPath: build.project.full_path, pipelineID: build.pipeline.iid } }
    let(:expected_dast_data) { { 'name' => 'foo', 'errors' => ['[foo] bar'] } }
    let(:query) do
      %(
        query getScanInfo($projectPath: ID!, $pipelineID: ID!) {
          project(fullPath: $projectPath) {
            pipeline(iid: $pipelineID) {
              securityReportSummary {
                dast {
                  vulnerabilitiesCount
                  scans {
                    nodes {
                      name
                      errors
                    }
                  }
                }
              }
            }
          }
        }
      )
    end

    subject(:scan_data) { response.dig('data', 'project', 'pipeline', 'securityReportSummary', 'dast', 'scans', 'nodes', 0) }

    before do
      stub_licensed_features(security_dashboard: true)

      build.project.add_developer(user)
      build.security_scans.first.update!(info: { 'errors' => [{ 'type' => 'foo', 'message' => 'bar' }] })
    end

    it 'returns the correct data' do
      expect(scan_data).to eq(expected_dast_data)
    end
  end
end
