# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'getting Alert Management Integrations' do
  include ::Gitlab::Routing.url_helpers
  include GraphqlHelpers

  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:current_user) { create(:user) }
  let_it_be(:payload_example) do
    {
      alert: {
        name: 'Alert name',
        desc: 'Alert description'
      }
    }
  end

  let_it_be(:payload_attribute_mapping) do
    {
      title: { path: %w(alert name), type: 'string' },
      description: { path: %w(alert desc), type: 'string' }
    }
  end

  let_it_be(:http_integration) do
    create(
      :alert_management_http_integration,
      project: project,
      payload_example: payload_example,
      payload_attribute_mapping: payload_attribute_mapping
    )
  end

  let(:fields) do
    <<~QUERY
      nodes {
        #{all_graphql_fields_for('AlertManagementHttpIntegration')}
      }
    QUERY
  end

  let(:query) do
    graphql_query_for(
      'project',
      { 'fullPath' => project.full_path },
      query_graphql_field('alertManagementHttpIntegrations', {}, fields)
    )
  end

  before do
    stub_licensed_features(multiple_alert_http_integrations: true)
    stub_feature_flags(multiple_http_integrations_custom_mapping: project)
  end

  context 'with integrations' do
    let(:integrations) { graphql_data.dig('project', 'alertManagementHttpIntegrations', 'nodes') }

    context 'without project permissions' do
      let(:user) { create(:user) }

      before do
        post_graphql(query, current_user: current_user)
      end

      it_behaves_like 'a working graphql query'

      specify { expect(integrations).to be_nil }
    end

    context 'with project permissions' do
      before do
        project.add_maintainer(current_user)
        post_graphql(query, current_user: current_user)
      end

      it_behaves_like 'a working graphql query'

      specify { expect(integrations.size).to eq(1) }

      it 'returns the correct properties of the integration' do
        expect(integrations).to include(
          {
            'id' => GitlabSchema.id_from_object(active_http_integration).to_s,
            'type' => 'HTTP',
            'name' => active_http_integration.name,
            'active' => active_http_integration.active,
            'token' => active_http_integration.token,
            'url' => active_http_integration.url,
            'apiUrl' => nil,
            'payloadExample' => 'hallo',
            'payloadAttributeMappings' => 503
          }
        )
      end
    end
  end
end
