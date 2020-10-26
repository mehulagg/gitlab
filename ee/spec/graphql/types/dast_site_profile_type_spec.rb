# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['DastSiteProfile'] do
  let_it_be(:dast_site_profile) { create(:dast_site_profile) }
  let_it_be(:project) { dast_site_profile.project }
  let_it_be(:user) { create(:user) }
  let_it_be(:fields) { %i[id profileName targetUrl editPath validationStatus userPermissions] }

  subject do
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

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  specify { expect(described_class.graphql_name).to eq('DastSiteProfile') }
  specify { expect(described_class).to require_graphql_authorizations(:create_on_demand_dast_scan) }
  specify { expect(described_class).to expose_permissions_using(Types::PermissionTypes::DastSiteProfile) }

  it { expect(described_class).to have_graphql_fields(fields) }

  describe 'dast_site_profiles' do
    before do
      project.add_developer(user)
    end

    let(:query) do
      %(
        query project($fullPath: ID!) {
          project(fullPath: $fullPath) {
            dastSiteProfiles(first: 1) {
              nodes {
                id
                profileName
                targetUrl
                editPath
                validationStatus
              }
            }
          }
        }
      )
    end

    let(:first_dast_site_profile) do
      subject.dig('data', 'project', 'dastSiteProfiles', 'nodes', 0)
    end

    describe 'id field' do
      it 'is a global id' do
        expect(first_dast_site_profile['id']).to eq(dast_site_profile.to_global_id.to_s)
      end
    end

    describe 'profile_name field' do
      it 'is the name' do
        expect(first_dast_site_profile['profileName']).to eq(dast_site_profile.name)
      end
    end

    describe 'target_url field' do
      it 'is the url of the associated dast_site' do
        expect(first_dast_site_profile['targetUrl']).to eq(dast_site_profile.dast_site.url)
      end
    end

    describe 'edit_path field' do
      it 'is the relative path to edit the dast_site_profile' do
        path = "/#{project.full_path}/-/security/configuration/dast_profiles/dast_site_profiles/#{dast_site_profile.id}/edit"

        expect(first_dast_site_profile['editPath']).to eq(path)
      end
    end

    describe 'validation_status field' do
      it 'is the validation status' do
        expect(first_dast_site_profile['validationStatus']).to eq('PENDING_VALIDATION')
      end
    end

    context 'when there are no dast_site_profiles' do
      let(:project) { create(:project) }

      it 'has no nodes' do
        nodes = subject.dig('data', 'project', 'dastSiteProfiles', 'nodes')

        expect(nodes).to be_empty
      end
    end
  end
end
