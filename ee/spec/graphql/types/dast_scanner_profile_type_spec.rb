# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['DastScannerProfile'] do
  let_it_be(:dast_scanner_profile) { create(:dast_scanner_profile) }
  let_it_be(:project) { dast_scanner_profile.project }
  let_it_be(:user) { create(:user) }
  let_it_be(:fields) { %i[id globalId profileName spiderTimeout targetTimeout editPath] }

  let(:response) do
    GitlabSchema.execute(
      query,
      context: {
        current_user: user
      },
      variables: {
        fullPath: project.full_path
      }
    ).as_json
  end

  subject { response }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  specify { expect(described_class.graphql_name).to eq('DastScannerProfile') }
  specify { expect(described_class).to require_graphql_authorizations(:create_on_demand_dast_scan) }

  it { expect(described_class).to have_graphql_fields(fields) }

  describe 'dast_scanner_profiles' do
    before do
      project.add_developer(user)
    end

    let(:query) do
      %(
        query project($fullPath: ID!) {
          project(fullPath: $fullPath) {
            dastScannerProfiles(first: 1) {
              nodes {
                id
                globalId
                profileName
                targetTimeout
                spiderTimeout
              }
            }
          }
        }
      )
    end

    let(:first_dast_scanner_profile) do
      response.dig('data', 'project', 'dastScannerProfiles', 'nodes', 0)
    end

    describe 'profile_name field' do
      subject { first_dast_scanner_profile['profileName'] }

      it { is_expected.to eq(dast_scanner_profile.name) }
    end
  end
end
