# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Extracting fields from alert payload' do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:maintainer) { create(:user) }
  let(:current_user) { maintainer }
  let(:variables) do
    {
      project_path: project.full_path,
      payload: payload_json
    }
  end

  let(:payload_json) { Gitlab::Json.generate(payload) }

  let(:payload) do
    {
      foo: {
        bar: 'value'
      }
    }
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
  end

  before do
    post_graphql_mutation(mutation, current_user: current_user)
  end

  it 'works' do
    expect(response).to have_gitlab_http_status(:success)
    expect(payload_alert_fields).to eq([
      {
        'path' => 'foo.bar',
        'label' => 'Bar',
        'type' => 'string'
      }
    ])
  end

  context 'without license'
  context 'without feature flag'
  context 'without user permission'
end
