# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Extracting fields from alert payload' do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:maintainer) { create(:user) }
  let_it_be(:developer) { create(:user) }
  let(:current_user) { maintainer }
  let(:variables) do
    {
      project_path: project.full_path,
      payload: payload_json
    }
  end

  let(:payload_json) do
    <<~JSON
      {
        "key": "value"
      }
    JSON
  end

  let(:mutation) do
    graphql_mutation(:alert_payload_extract_fields, variables) do
      <<~QL
        payloadAlertFields {
          path
          label
          type
        }
      QL
    end
  end

  let(:mutation_response) { graphql_mutation_response(:alert_payload_extract_fields) }
  let(:payload_alert_fields) { mutation_response.fetch('payloadAlertFields') }

  before_all do
    project.add_maintainer(maintainer)
    project.add_developer(developer)
  end

  before do
    stub_licensed_features(multiple_alert_http_integrations: true)
    post_graphql_mutation(mutation, current_user: current_user)
  end

  it 'returns parsed alert fields from sample payload' do
    expect(response).to have_gitlab_http_status(:success)
    expect(payload_alert_fields).to eq([
      {
        'path' => 'key',
        'label' => 'Key',
        'type' => 'string'
      }
    ])
  end

  context 'without license' do
    before do
      stub_licensed_features(multiple_alert_http_integrations: false)
    end

    it_behaves_like 'a mutation that returns a top-level access error'
  end

  context 'without feature flag' do
    before do
      stub_feature_flags(multiple_http_integrations_custom_mapping: false)
    end

    it_behaves_like 'a mutation that returns a top-level access error'
  end

  context 'without user permission' do
    let(:current_user) { developer }

    it_behaves_like 'a mutation that returns a top-level access error'
  end
end
