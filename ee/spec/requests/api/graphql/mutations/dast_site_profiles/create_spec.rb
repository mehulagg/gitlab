# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Creating a DAST Site Profile' do
  include GraphqlHelpers

  let(:profile_name) { FFaker::Company.catch_phrase }
  let(:target_url) { generate(:url) }
  let(:dast_site_profile) { DastSiteProfile.find_by(project: project, name: profile_name) }

  let(:mutation_name) { :dast_site_profile_create }
  let(:mutation) do
    graphql_mutation(
      mutation_name,
      full_path: full_path,
      profile_name: profile_name,
      target_url: target_url
    )
  end

  it_behaves_like 'an on-demand scan mutation when user cannot run an on-demand scan'
  it_behaves_like 'an on-demand scan mutation when user can run an on-demand scan' do
    it 'returns the dast_site_profile id' do
      subject

      expect(mutation_response).to include('id' => global_id_of(dast_site_profile))
    end
  end
end
