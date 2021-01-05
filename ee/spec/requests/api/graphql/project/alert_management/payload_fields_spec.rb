# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'parse alert payload fields' do
  include GraphqlHelpers

  let_it_be_with_refind(:project) { create(:project) }
  let_it_be(:maintainer) { create(:user) }
  let_it_be(:developer) { create(:user) }
  let(:current_user) { maintainer }
  let(:license) { true }
  let(:feature_flag) { true }

  let(:payload) do
    {
      'title' => 'value',
      'amount' => 23,
      'started_at' => '2020-01-02 04:05:06',
      'nested' => {
        'key' => 'string'
      }
    }
  end

  let(:payload_json) { Gitlab::Json.generate(payload) }
  let(:arguments) { { payload: payload_json } }

  let(:fields) { all_graphql_fields_for('AlertManagementPayloadAlertField') }

  let(:query) do
    graphql_query_for(
      'project',
      { 'fullPath' => project.full_path },
      query_graphql_field('alertManagementPayloadFields', arguments, fields)
    )
  end

  let(:parsed_fields) do
    graphql_data.dig('project', 'alertManagementPayloadFields')
  end

  before_all do
    project.add_developer(developer)
    project.add_maintainer(maintainer)
  end

  before do
    stub_licensed_features(multiple_alert_http_integrations: license)
    stub_feature_flags(multiple_http_integrations_custom_mapping: feature_flag)

    post_graphql(query, current_user: current_user)
  end

  it_behaves_like 'a working graphql query'

  specify do
    expect(parsed_fields).to eq([
      { 'path' => ['title'], 'label' => 'Title', 'type' => 'string' },
      { 'path' => ['amount'], 'label' => 'Amount', 'type' => 'numeric' },
      { 'path' => ['started_at'], 'label' => 'Started at', 'type' => 'datetime' },
      { 'path' => ['nested', 'key'], 'label' => 'Key', 'type' => 'string' }
    ])
  end

  shared_examples 'query with error' do |error_message|
    it 'returns an error', :aggregate_failures do
      expect(parsed_fields).to be_nil

      expect(graphql_errors)
        .to include(a_hash_including('message' => error_message))
    end
  end

  context 'without user permission' do
    let(:current_user) { developer }

    it_behaves_like 'query with error', 'Insufficient permissions'
  end

  context 'without license' do
    let(:license) { false }

    it_behaves_like 'query with error', 'Feature not available'
  end

  context 'with invalid payload JSON' do
    let(:payload_json) { 'invalid json' }

    it_behaves_like 'query with error', 'Failed to parse payload'
  end

  context 'with non-Hash JSON' do
    let(:payload_json) { '1' }

    it_behaves_like 'query with error', 'Failed to parse payload'
  end

  context 'without feature flag' do
    let(:feature_flag) { false }

    it_behaves_like 'query with error', 'Feature not available'
  end
end
