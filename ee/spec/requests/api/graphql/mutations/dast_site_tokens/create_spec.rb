# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Creating a DAST Site Token' do
  include GraphqlHelpers

  let(:target_url) { generate(:url) }
  let(:dast_site_token) { DastSiteToken.find_by!(project: project, token: uuid) }
  let(:uuid) { '0000-0000-0000-0000' }

  let(:mutation_name) { :dast_site_token_create }
  let(:mutation) do
    graphql_mutation(
      mutation_name,
      full_path: full_path,
      target_url: target_url
    )
  end

  before do
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
  end

  it_behaves_like 'an on-demand scan mutation when user cannot run an on-demand scan'
  it_behaves_like 'an on-demand scan mutation when user can run an on-demand scan' do
    it 'returns the dast_site_token id' do
      subject

      expect(mutation_response["id"]).to eq(dast_site_token.to_global_id.to_s)
    end

    it 'creates a new dast_site_token' do
      expect { subject }.to change { DastSiteToken.count }.by(1)
    end
  end
end
