# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'snippets' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }

  let_it_be(:snippets) { create_list(:personal_snippet, 3, :repository, author: current_user) }

  describe 'querying for all fields' do
    let(:query) do
      graphql_query_for(:snippets, { ids: [global_id_of(snippets.first)] }, <<~SELECT)
        nodes { #{all_graphql_fields_for('Snippet')} }
      SELECT
    end

    it 'can successfully query for snippets and their blobs' do
      post_graphql(query, current_user: current_user)

      expect(graphql_data_at(:snippets, :nodes)).to be_one
      expect(graphql_data_at(:snippets, :nodes, :blobs, :nodes)).to be_present
    end
  end

  describe 'snippet_blob_content' do
    let_it_be(:query_file) do
      Pathname.new(Rails.root.join('app/graphql/queries/snippet/snippet_blob_content.query.graphql'))
    end

    it 'can query for rich snippet blob content' do
      ids = snippets.map { |s| global_id_of(s) }
      vars = {
        rich: true,
        paths: ['.gitattributes'],
        ids: ids
      }

      post_graphql(query_file.read, current_user: current_user, variables: vars)

      expect(graphql_data_at(:snippets, :nodes, :blobs, :nodes, :path))
        .to contain_exactly('.gitattributes', '.gitattributes', '.gitattributes')
    end

    it 'can query for plain snippet blob content' do
      ids = snippets.map { |s| global_id_of(s) }
      vars = {
        rich: false,
        paths: ['.gitattributes'],
        ids: ids
      }

      post_graphql(query_file.read, current_user: current_user, variables: vars)

      expect(graphql_data_at(:snippets, :nodes, :blobs, :nodes, :path))
        .to contain_exactly('.gitattributes', '.gitattributes', '.gitattributes')
    end
  end
end
