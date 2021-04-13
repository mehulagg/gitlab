# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'getting blobs in a project repository' do
  include GraphqlHelpers

  let(:project) { create(:project, :repository) }
  let(:current_user) { project.owner }
  let(:path) { "README.md" }
  let(:ref) { 'master' }
  let(:fields) do
    <<~QUERY
      blobs(paths:["#{path}"], ref:"#{ref}") {
        nodes {
          #{all_graphql_fields_for('blobs'.classify)}
        }
      }
    QUERY
  end

  let(:query) do
    graphql_query_for(
      'project',
      { 'fullPath' => project.full_path },
      query_graphql_field('repository', {}, fields)
    )
  end

  subject(:blobs) { graphql_data_at(:project, :repository, :blobs, :nodes) }

  it 'returns the blob' do
    post_graphql(query, current_user: current_user)

    expect(blobs).to contain_exactly(
      a_hash_including('flatPath' => path, 'path' => path, 'type' => 'blob')
    )
  end
end
