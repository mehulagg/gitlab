# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Querying an Iteration' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:iteration) { create(:iteration, group: group) }

  let(:query) do
    graphql_query_for('iteration', { id: iteration.to_global_id.to_s }, 'title')
  end

  subject { graphql_data['iteration'] }

  before do
    post_graphql(query, current_user: current_user)
  end

  context 'when the user has access to the iteration' do
    before_all do
      group.add_guest(current_user)
    end

    it_behaves_like 'a working graphql query'

    it { is_expected.to include('title' => iteration.name) }
  end

  context 'when the user does not have access to the iteration' do
    it_behaves_like 'a working graphql query'

    it { is_expected.to be_nil }
  end

  context 'when ID argument is missing' do
    let(:query) do
      graphql_query_for('iteration', {}, 'title')
    end

    it 'raises an exception' do
      expect(graphql_errors).to include(a_hash_including('message' => "Field 'iteration' is missing required arguments: id"))
    end
  end

  describe 'scoped path' do
    let_it_be(:project) { create(:project, :private, group: group) }
    let_it_be(:project_iteration) { create(:iteration, :skip_project_validation, project: project) }

    shared_examples 'scoped path' do
      let(:queried_iteration_id) { queried_iteration.to_global_id.to_s }
      let(:iteration_nodes) do
        nodes = <<~NODES
          nodes {
            scopedPath
            scopedUrl
            webPath
            webUrl
          }
        NODES

        query_graphql_field('iterations', { id: queried_iteration_id }, nodes)
      end

      before_all do
        group.add_guest(current_user)
      end

      specify do
        expect(subject).to include(
          'scopedPath' => expected_scope_path,
          'scopedUrl' => expected_scope_url,
          'webPath' => expected_web_path,
          'webUrl' => expected_web_url
        )
      end

      context 'when given a raw model id (backward compatibility)' do
        let(:queried_iteration_id) { queried_iteration.id }

        specify do
          expect(subject).to include(
            'scopedPath' => expected_scope_path,
            'scopedUrl' => expected_scope_url,
            'webPath' => expected_web_path,
            'webUrl' => expected_web_url
          )
        end
      end
    end

    context 'inside a project context' do
      subject { graphql_data['project']['iterations']['nodes'].first }

      let(:query) do
        graphql_query_for('project', { full_path: project.full_path }, iteration_nodes)
      end

      describe 'group-owned iteration' do
        it_behaves_like 'scoped path' do
          let(:queried_iteration) { iteration }
          let(:expected_scope_path) { project_iteration_path(project, iteration.id) }
          let(:expected_scope_url) { /#{expected_scope_path}$/ }
          let(:expected_web_path) { group_iteration_path(group, iteration.id) }
          let(:expected_web_url) { /#{expected_web_path}$/ }
        end
      end
    end

    context 'inside a group context' do
      subject { graphql_data['group']['iterations']['nodes'].first }

      let(:query) do
        graphql_query_for('group', { full_path: group.full_path }, iteration_nodes)
      end

      describe 'group-owned iteration' do
        it_behaves_like 'scoped path' do
          let(:queried_iteration) { iteration }
          let(:expected_scope_path) { group_iteration_path(group, iteration.id) }
          let(:expected_scope_url) { /#{expected_scope_path}$/ }
          let(:expected_web_path) { group_iteration_path(group, iteration.id) }
          let(:expected_web_url) { /#{expected_web_path}$/ }
        end
      end

      describe 'group-owned iteration' do
        let(:sub_group) { create(:group, :private, parent: group) }
        let(:query) do
          graphql_query_for('group', { full_path: sub_group.full_path }, iteration_nodes)
        end

        it_behaves_like 'scoped path' do
          let(:queried_iteration) { iteration }
          let(:expected_scope_path) { group_iteration_path(sub_group, iteration.id) }
          let(:expected_scope_url) { /#{expected_scope_path}$/ }
          let(:expected_web_path) { group_iteration_path(group, iteration.id) }
          let(:expected_web_url) { /#{expected_web_path}$/ }
        end
      end
    end

    context 'root context' do
      subject { graphql_data['iteration'] }

      let(:query) do
        graphql_query_for('iteration', { id: iteration.to_global_id.to_s }, [:scoped_path, :scoped_url, :web_path, :web_url])
      end

      describe 'group-owned iteration' do
        it_behaves_like 'scoped path' do
          let(:queried_iteration) { iteration }
          let(:expected_scope_path) { group_iteration_path(group, iteration.id) }
          let(:expected_scope_url) { /#{expected_scope_path}$/ }
          let(:expected_web_path) { group_iteration_path(group, iteration.id) }
          let(:expected_web_url) { /#{expected_web_path}$/ }
        end
      end

      describe 'project-owned iteration' do
        it_behaves_like 'scoped path' do
          let(:queried_iteration) { project_iteration }
          let(:expected_scope_path) { group_iteration_path(group, iteration.id) }
          let(:expected_scope_url) { /#{expected_scope_path}$/ }
          let(:expected_web_path) { group_iteration_path(group, iteration.id) }
          let(:expected_web_url) { /#{expected_web_path}$/ }
        end
      end
    end
  end
end
