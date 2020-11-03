# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Removing an HTTP Integration' do
  include GraphqlHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:integration) { create(:alert_management_http_integration, project: project) }

  let(:mutation) do
    variables = {
      id: GitlabSchema.id_from_object(integration).to_s
    }
    graphql_mutation(:http_integration_destroy, variables) do
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

  let(:mutation_response) { graphql_mutation_response(:http_integration_destroy) }

  before do
    project.add_maintainer(user)
  end

  it 'removes the integration' do
    post_graphql_mutation(mutation, current_user: user)

    expect(response).to have_gitlab_http_status(:success)
    expect(mutation_response['integration']['id']).to eq(GitlabSchema.id_from_object(integration).to_s)
    expect { integration.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
