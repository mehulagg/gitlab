# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Namespace.projects' do
  include GraphqlHelpers

  describe 'sorting and pagination' do
    let_it_be(:ns) { create(:group) }
    let_it_be(:current_user) { create(:user) }

    let!(:project_1) { create(:project, namespace: ns, name: 'Project', path: 'project') }
    let!(:project_2) { create(:project, namespace: ns, name: 'Test Project', path: 'test-project') }
    let!(:project_3) { create(:project, namespace: ns, name: 'Test', path: 'test') }
    let!(:project_4) { create(:project, namespace: ns, name: 'Test Project Other', path: 'other-test-project') }

    let(:data_path) { [:namespace, :projects] }

    let(:ns_args) { graphql_args(full_path: ns.full_path) }
    let(:project_args) { graphql_args(include_subgroups: true, search: 'test') }

    before do
      ns.add_owner(current_user)
    end

    def pagination_query(params, page_info)
      graphql_query_for(:namespace, ns_args,
        query_graphql_field(:projects, params + project_args, "#{page_info} edges { node { name } }"))
    end

    def pagination_results_data(data)
      data.map { |project| project.dig('node', 'name') }
    end

    context 'when sorting by STORAGE' do
      before do
        project_4.statistics.update!(lfs_objects_size: 1, repository_size: 4.gigabytes)
        project_2.statistics.update!(lfs_objects_size: 1, repository_size: 2.gigabytes)
        project_3.statistics.update!(lfs_objects_size: 2, repository_size: 1.gigabytes)
      end

      it_behaves_like 'sorted paginated query' do
        let(:sort_param)       { :STORAGE }
        let(:first_param)      { 2 }
        let(:expected_results) { [project_4, project_2, project_3].map(&:name) }
      end

      it_behaves_like 'sorted pagable query' do
        let!(:project_5) { create(:project, namespace: ns, name: 'Test 5') }
        let!(:project_6) { create(:project, namespace: ns, name: 'Test 6') }
        let!(:project_7) { create(:project, namespace: ns, name: 'Test 7') }
        let!(:project_8) { create(:project, namespace: ns, name: 'Test 8') }

        let(:all_results) { expected_order.map { |p| { 'name' => p.name } } }
        let(:sort_value)  { :STORAGE }
        let(:expected_order) do
          # Some jumbled random order, to ensure we aren't testing ID desc or asc
          [project_5, project_3, project_7, project_8, project_2, project_6, project_4]
        end

        before do
          expected_order.reverse.each_with_index do |p, i|
            n = i + 1
            p.statistics.update!(lfs_objects_size: n, repository_size: n.gigabytes)
          end
        end

        def paging_query(params)
          graphql_query_for(:namespace, ns_args,
            query_graphql_field(:projects, params + project_args, "#{page_info} nodes { name }"))
        end
      end
    end
  end
end
