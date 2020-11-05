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

      expect(mutation_response["id"]).to eq(dast_site_profile.to_global_id.to_s)
    end

    context 'when an unknown error occurs' do
      before do
        allow(DastSiteProfile).to receive(:create!).and_raise(StandardError)
      end

      it_behaves_like 'a mutation that returns top-level errors', errors: ['Internal server error']
    end
  end
end
