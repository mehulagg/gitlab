# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Creating a new HTTP Integration' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }

  let(:payload_example) do
    {
      'alert' => { 'name' => 'Test alert' },
      'started_at' => Time.current.strftime('%d %B %Y, %-l:%M%p (%Z)')
    }.to_json
  end

  let(:payload_attribute_mappings) do
    [
      { fieldName: 'TITLE', path: %w[alert name], type: 'STRING' },
      { fieldName: 'START_TIME', path: %w[started_at], type: 'DATETIME', label: 'Start time' }
    ]
  end

  let(:variables) do
    {
      project_path: project.full_path,
      active: false,
      name: 'New HTTP Integration',
      payload_example: payload_example,
      payload_attribute_mappings: payload_attribute_mappings
    }
  end

  let(:mutation) do
    graphql_mutation(:http_integration_create, variables) do
      <<~QL
         clientMutationId
         errors
         integration {
           id
           type
           name
           active
           token
           url
           apiUrl
         }
      QL
    end
  end

  let(:mutation_response) { graphql_mutation_response(:http_integration_create) }

  shared_examples 'ignoring the custom mapping' do
    it 'creates integration without the custom mapping params' do
      post_graphql_mutation(mutation, current_user: current_user)

      new_integration = ::AlertManagement::HttpIntegration.last!
      integration_response = mutation_response['integration']

      expect(response).to have_gitlab_http_status(:success)
      expect(integration_response['id']).to eq(GitlabSchema.id_from_object(new_integration).to_s)

      expect(new_integration.payload_example).to eq({})
      expect(new_integration.payload_attribute_mapping).to eq({})
    end
  end

  before do
    project.add_maintainer(current_user)

    stub_licensed_features(multiple_alert_http_integrations: true)
    stub_feature_flags(multiple_http_integrations_custom_mapping: project)
  end

  it_behaves_like 'creating a new HTTP integration'

  it 'stores the custom mapping params' do
    post_graphql_mutation(mutation, current_user: current_user)

    new_integration = ::AlertManagement::HttpIntegration.last!

    expect(new_integration.payload_example).to eq(Gitlab::Json.parse(payload_example))
    expect(new_integration.payload_attribute_mapping).to eq(
      {
        'title' => { 'path' => %w[alert name], 'type' => 'string', 'label' => nil },
        'start_time' => { 'path' => %w[started_at], 'type' => 'datetime', 'label' => 'Start time' }
      }
    )
  end

  [:project_path, :active, :name].each do |argument|
    context "without required argument #{argument}" do
      before do
        variables.delete(argument)
      end

      it_behaves_like 'an invalid argument to the mutation', argument_name: argument
    end
  end

  context 'with the custom mappings feature unavailable' do
    before do
      stub_licensed_features(multiple_alert_http_integrations: false)
    end

    it_behaves_like 'ignoring the custom mapping'
  end

  context 'with multiple_http_integrations_custom_mapping feature flag disabled' do
    before do
      stub_feature_flags(multiple_http_integrations_custom_mapping: false)
    end

    it_behaves_like 'ignoring the custom mapping'
  end

  it_behaves_like 'validating the payload_example'
  it_behaves_like 'validating the payload_attribute_mappings'
end
