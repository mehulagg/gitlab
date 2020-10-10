# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Track Usage Ping event' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let(:input) { { event: event } }
  let(:event) { 'static_site_editor_commit' }

  let(:mutation) { graphql_mutation(:track_usage_ping_event, input) }
  let(:mutation_response) { graphql_mutation_response(:track_usage_ping_event) }

  it 'creates a new usage ping event' do
    post_graphql_mutation(mutation, current_user: current_user)

    expect(response).to have_gitlab_http_status(:success)
    expect(mutation_response['errors']).to be_empty
  end

  context 'when event is not supported' do
    let(:event) { 'unknown' }

    it_behaves_like 'a mutation that returns errors in the response',
                    errors: ['Unsupported event']
  end
end
