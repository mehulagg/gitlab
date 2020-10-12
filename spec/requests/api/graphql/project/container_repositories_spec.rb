# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'getting container repositories in a project' do
  using RSpec::Parameterized::TableSyntax
  include GraphqlHelpers

  let_it_be(:project, reload: true) { create(:project, :private) }
  let_it_be(:container_repositories) { create_list(:container_repository, 5, project: project) }
  let_it_be(:container_expiration_policy) { project.container_expiration_policy }

  let(:fields) do
    <<~QUERY
    edges {
      node {
        #{all_graphql_fields_for('container_repositories'.classify)}
      }
    }
    QUERY
  end

  let(:query) do
    graphql_query_for(
      'project',
      { 'fullPath' => project.full_path },
      query_graphql_field('container_repositories', {}, fields)
    )
  end

  let(:user) { project.owner }
  let(:variables) { {} }
  let(:container_repositories_response) { graphql_data.dig('project', 'containerRepositories', 'edges') }

  before do
    stub_container_registry_config(enabled: true)
    container_repositories.each do |repository|
      stub_container_registry_tags(repository: repository.path, tags: %w(tag1 tag2 tag3), with_manifest: false)
    end
  end

  subject { post_graphql(query, current_user: user, variables: variables) }

  it_behaves_like 'a working graphql query' do
    before do
      subject
    end
  end

  context 'with different permissions' do
    let_it_be(:user) { create(:user) }

    where(:role, :access_granted) do
      :maintainer | true
      :reporter   | true
      :developer  | true
      :guest      | false
      :anonymous  | false
    end

    with_them do
      before do
        project.add_user(user, role) unless role == :anonymous
      end

      it 'return the proper response' do
        subject

        if access_granted
          expect(container_repositories_response.size).to eq(container_repositories.size)
        else
          expect(container_repositories_response).to eq(nil)
        end
      end
    end
  end

  context 'limiting the number of repositories' do
    let(:issue_limit) { 1 }
    let(:variables) do
      { path: project.full_path, n: issue_limit }
    end

    let(:query) do
      <<~GQL
        query($path: ID!, $n: Int) {
          project(fullPath: $path) {
            containerRepositories(first: $n) { #{fields} }
          }
        }
      GQL
    end

    it 'only returns N issues' do
      subject

      expect(container_repositories_response.size).to eq(issue_limit)
    end
  end

  context 'filter by name' do
    let_it_be(:container_repository) { create(:container_repository, name: 'fooBar', project: project) }

    let(:name) { 'ooba' }
    let(:query) do
      <<~GQL
        query($path: ID!, $name: String) {
          project(fullPath: $path) {
            containerRepositories(name: $name) { #{fields} }
          }
        }
      GQL
    end

    let(:variables) do
      { path: project.full_path, name: name }
    end

    before do
      stub_container_registry_tags(repository: container_repository.path, tags: %w(tag4 tag5 tag6), with_manifest: false)
    end

    it 'returns the searched container repository' do
      subject

      expect(container_repositories_response.size).to eq(1)
      expect(container_repositories_response.first.dig('node', 'id')).to eq(container_repository.to_global_id.to_s)
    end
  end
end
