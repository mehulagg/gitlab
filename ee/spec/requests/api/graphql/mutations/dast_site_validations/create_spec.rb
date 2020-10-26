# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Creating a DAST Site Token' do
  include GraphqlHelpers

  let(:dast_site_token) { create(:dast_site_token, project: project) }
  let(:dast_site_validation) { DastSiteValidation.find_by!(url_path: validation_path) }
  let(:validation_path) { SecureRandom.hex }

  let(:mutation_name) { :dast_site_validation_create }
  let(:mutation) do
    graphql_mutation(
      mutation_name,
      full_path: full_path,
      dast_site_token_id: dast_site_token.to_global_id.to_s,
      validation_path: validation_path,
      strategy: Types::DastSiteValidationStrategyEnum.values['TEXT_FILE'].graphql_name
    )
  end

  it_behaves_like 'an on-demand scan mutation when user cannot run an on-demand scan'
  it_behaves_like 'an on-demand scan mutation when user can run an on-demand scan' do
    it 'returns the dast_site_validation id' do
      subject

      expect(mutation_response["id"]).to eq(dast_site_validation.to_global_id.to_s)
    end

    it 'creates a new dast_site_validation' do
      expect { subject }.to change { DastSiteValidation.count }.by(1)
    end
  end
end
