# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'getting a requirement list for a project' do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:current_user) { create(:user) }
  let_it_be(:requirement) { create(:requirement, project: project) }

  let(:requirements_data) { graphql_data['project']['requirements']['edges'] }
  let(:fields) do
    <<~QUERY
    edges {
      node {
        #{all_graphql_fields_for('requirements'.classify)}
      }
    }
    QUERY
  end

  let(:query) do
    graphql_query_for(
      'project',
      { 'fullPath' => project.full_path },
      query_graphql_field('requirements', {}, fields)
    )
  end

  context 'when user has access to the project' do
    before do
      stub_licensed_features(requirements: true)
      project.add_developer(current_user)
    end

    it_behaves_like 'a working graphql query' do
      before do
        post_graphql(query, current_user: current_user)
      end
    end

    it 'returns requirements successfully' do
      post_graphql(query, current_user: current_user)

      expect(graphql_errors).to be_nil
      expect(requirements_data[0]['node']['id']).to eq requirement.to_global_id.to_s
    end

    context 'when limiting the number of results' do
      let(:query) do
        graphql_query_for(
          'project',
          { 'fullPath' => project.full_path },
          "requirements(first: 1) { #{fields} }"
        )
      end

      it_behaves_like 'a working graphql query' do
        before do
          post_graphql(query, current_user: current_user)
        end
      end
    end

    describe 'filtering' do
      let_it_be(:filter_project) { create(:project, :public) }
      let_it_be(:other_project) { create(:project, :public) }
      let_it_be(:other_user) { create(:user, username: 'number8wire') }
      let_it_be(:requirement1) { create(:requirement, project: filter_project, author: current_user, title: 'solve the halting problem') }
      let_it_be(:requirement2) { create(:requirement, project: filter_project, author: other_user, title: 'something about kubernetes') }

      before do
        post_graphql(query, current_user: current_user)
      end

      let(:requirements_data) { graphql_data['project']['requirements']['nodes'] }
      let(:params) { "" }

      let(:query) do
        graphql_query_for(
          'project',
          { 'fullPath' => filter_project.full_path },
          <<~REQUIREMENTS
            requirements#{params} {
              nodes {
                id
              }
            }
          REQUIREMENTS
        )
      end

      it_behaves_like 'a working graphql query'

      def match_single_result(requirement)
        expect(requirements_data[0]['id']).to eq requirement.to_global_id.to_s
      end

      context 'when given single author param' do
        let(:params) { '(authorUsername: "number8wire")' }

        it 'returns filtered requirements' do
          expect(graphql_errors).to be_nil
          match_single_result(requirement2)
        end
      end

      context 'when given multiple author param' do
        let(:params) { '(authorUsername: ["number8wire", "someotheruser"])' }

        it 'returns filtered requirements' do
          expect(graphql_errors).to be_nil
          match_single_result(requirement2)
        end
      end

      context 'when given search param' do
        let(:params) { '(search: "halting")' }

        it 'returns filtered requirements' do
          expect(graphql_errors).to be_nil
          match_single_result(requirement1)
        end
      end

      context 'when given author and search params' do
        let(:params) { '(search: "kubernetes", authorUsername: "number8wire")' }

        it 'returns filtered requirements' do
          expect(graphql_errors).to be_nil
          match_single_result(requirement2)
        end
      end
    end

    describe 'sorting and pagination' do
      let_it_be(:data_path) { [:project, :requirements] }

      def pagination_query(params, page_info)
        graphql_query_for(
          'project',
          { 'fullPath' => sort_project.full_path },
          query_graphql_field('requirements', params, "#{page_info} edges { node { iid createdAt} }")
        )
      end

      def pagination_results_data(data)
        data.map { |issue| issue.dig('node', 'iid').to_i }
      end

      context 'when sorting by created_at' do
        let_it_be(:sort_project) { create(:project, :public) }
        let_it_be(:requirement1) { create(:requirement, project: sort_project, created_at: 3.days.from_now) }
        let_it_be(:requirement2) { create(:requirement, project: sort_project, created_at: 4.days.from_now) }
        let_it_be(:requirement3) { create(:requirement, project: sort_project, created_at: 2.days.ago) }
        let_it_be(:requirement4) { create(:requirement, project: sort_project, created_at: 5.days.ago) }
        let_it_be(:requirement5) { create(:requirement, project: sort_project, created_at: 1.day.ago) }

        context 'when ascending' do
          it_behaves_like 'sorted paginated query' do
            let(:sort_param)       { 'created_asc' }
            let(:first_param)      { 2 }
            let(:expected_results) { [requirement4.iid, requirement3.iid, requirement5.iid, requirement1.iid, requirement2.iid] }
          end
        end

        context 'when descending' do
          it_behaves_like 'sorted paginated query' do
            let(:sort_param)       { 'created_desc' }
            let(:first_param)      { 2 }
            let(:expected_results) { [requirement2.iid, requirement1.iid, requirement5.iid, requirement3.iid, requirement4.iid] }
          end
        end
      end
    end
  end

  context 'when the user does not have access to the requirement' do
    before do
      stub_licensed_features(requirements: true)
    end

    it 'returns nil' do
      post_graphql(query)

      expect(graphql_data['project']).to be_nil
    end
  end

  context 'when requirements feature is not available' do
    before do
      stub_licensed_features(requirements: false)
      project.add_developer(current_user)
    end

    it 'returns nil' do
      post_graphql(query)

      expect(graphql_data['project']).to be_nil
    end
  end
end
