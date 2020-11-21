# frozen_string_literal: true

# Use this for testing how a GraphQL query handles sorting and pagination.
# This is particularly important when using keyset pagination connection,
# which is the default for ActiveRecord relations, as certain sort keys
# might not be supportable.
#
# sort_param: the value to specify the sort
# data_path: the keys necessary to dig into the return GraphQL data to get the
#   returned results
# first_param: number of items expected (like a page size)
# expected_results: array of comparison data of all items sorted correctly
# pagination_query: method that specifies the GraphQL query
# pagination_results_data: method that extracts the sorted data used to compare against
#   the expected results
#
# Example:
#   describe 'sorting and pagination' do
#     let(:sort_project) { create(:project, :public) }
#     let(:data_path)    { [:project, :issues] }
#
#     def pagination_query(params, page_info)
#       graphql_query_for(
#         'project',
#         { 'fullPath' => sort_project.full_path },
#         query_graphql_field('issues', params, "#{page_info} edges { node { id } }")
#       )
#     end
#
#     def pagination_results_data(data)
#       data.map { |issue| issue.dig('node', 'iid').to_i }
#     end
#
#     context 'when sorting by weight' do
#       ...
#       context 'when ascending' do
#         it_behaves_like 'sorted paginated query' do
#           let(:sort_param)       { 'WEIGHT_ASC' }
#           let(:first_param)      { 2 }
#           let(:expected_results) { [weight_issue3.iid, weight_issue5.iid, weight_issue1.iid, weight_issue4.iid, weight_issue2.iid] }
#         end
#       end
#
RSpec.shared_examples 'sorted paginated query' do
  it_behaves_like 'requires variables' do
    let(:required_variables) { [:sort_param, :first_param, :expected_results, :data_path, :current_user] }
  end

  describe do
    let(:sort_argument)  { graphql_args(sort: sort_param) }
    let(:params)         { sort_argument }
    let(:page_info)      { "pageInfo { startCursor endCursor }" }

    def pagination_query(params, page_info)
      raise('pagination_query(params, page_info) must be defined in the test, see example in comment') unless defined?(super)

      super
    end

    def pagination_results_data(data)
      raise('pagination_results_data(data) must be defined in the test, see example in comment') unless defined?(super)

      super(data)
    end

    def results
      edges = graphql_dig_at(graphql_data(fresh_response_data), *data_path, :edges)
      pagination_results_data(edges)
    end

    def end_cursor
      graphql_dig_at(graphql_data(fresh_response_data), *data_path, :page_info, :end_cursor)
    end

    let(:query) { pagination_query(params, page_info) }

    before do
      post_graphql(query, current_user: current_user)
    end

    context 'when sorting' do
      it 'sorts correctly' do
        expect(results).to eq expected_results
      end

      context 'when paginating' do
        let(:params) { sort_argument.merge(first: first_param) }
        let(:first_page) { expected_results.first(first_param) }
        let(:rest) { expected_results.drop(first_param) }

        it 'paginates correctly' do
          expect(results).to eq first_page

          cursored_query = pagination_query(sort_argument.merge(after: end_cursor), page_info)
          post_graphql(cursored_query, current_user: current_user)

          expect(results).to eq rest
        end
      end
    end
  end
end

RSpec.shared_examples 'sorted pagable query' do
  let(:sort_argument)  { graphql_args(sort: sort_value) }
  let(:page_info)      { "pageInfo { startCursor endCursor }" }

  def paging_query(params)
    raise('paging_query(params) must be defined in the test, see example in comment') unless defined?(super)

    super
  end

  def nodes
    graphql_dig_at(graphql_data(fresh_response_data), *data_path, :nodes)
  end

  def end_cursor
    graphql_dig_at(graphql_data(fresh_response_data), *data_path, :page_info, :end_cursor)
  end

  context 'when sorting' do
    it 'sorts correctly' do
      post_graphql(paging_query(sort_argument), current_user: current_user)

      expect(nodes).to eq all_results
    end

    it 'has at least 5 items' do
      # We need to page a few times - this makes sure we can page at least twice
      expect(all_results.size).to be >= 5
    end

    context 'when paginating' do
      let(:page_size) { 2 }

      it 'paginates correctly' do
        all_results.in_groups_of(page_size, false).reduce(nil) do |cursor, group|
          q = paging_query(sort_argument.merge(first: page_size, after: cursor))

          post_graphql(q, current_user: current_user)

          expect(nodes).to eq(group)

          end_cursor
        end
      end
    end
  end
end
