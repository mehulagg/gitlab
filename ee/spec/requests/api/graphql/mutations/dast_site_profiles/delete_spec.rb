# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Creating a DAST Site Profile' do
  include GraphqlHelpers

  let!(:dast_site_profile) { create(:dast_site_profile, project: project) }

  let(:mutation_name) { :dast_site_profile_delete }
  let(:mutation) do
    graphql_mutation(
      mutation_name,
      full_path: full_path,
      id: dast_site_profile.to_global_id.to_s
    )
  end

  it_behaves_like 'an on-demand scan mutation when user cannot run an on-demand scan'
  it_behaves_like 'an on-demand scan mutation when user can run an on-demand scan' do
    it 'deletes the dast_site_profile' do
      expect { subject }.to change { DastSiteProfile.count }.by(-1)
    end

    context 'when there is an issue deleting the dast_site_profile' do
      before do
        mutation_klass = Mutations::DastSiteProfiles::Delete
        allow_any_instance_of(mutation_klass).to receive(:find_dast_site_profile).and_return(dast_site_profile)
        allow(dast_site_profile).to receive(:destroy).and_return(false)
        dast_site_profile.errors.add(:name, 'is weird')
      end

      it_behaves_like 'a mutation that returns errors in the response', errors: ['Name is weird']
    end

    context 'when the dast_site_profile does not exist' do
      before do
        dast_site_profile.destroy!
      end

      it_behaves_like 'a mutation that returns top-level errors', errors: ['Internal server error']
    end

    context 'when wrong type of global id is passed' do
      let(:mutation) do
        graphql_mutation(
          mutation_name,
          full_path: full_path,
          id: dast_site_profile.dast_site.to_global_id.to_s
        )
      end

      it_behaves_like 'a mutation that returns top-level errors' do
        let(:match_errors) do
          gid = dast_site_profile.dast_site.to_global_id

          eq(["Variable $dastSiteProfileDeleteInput of type DastSiteProfileDeleteInput! " \
              "was provided invalid value for id (\"#{gid}\" does not represent an instance " \
              "of DastSiteProfile)"])
        end
      end
    end

    context 'when the dast_site_profile belongs to a different project' do
      let(:mutation) do
        graphql_mutation(
          mutation_name,
          full_path: create(:project).full_path,
          id: dast_site_profile.to_global_id.to_s
        )
      end

      it_behaves_like 'a mutation that returns a top-level access error'
    end
  end
end
