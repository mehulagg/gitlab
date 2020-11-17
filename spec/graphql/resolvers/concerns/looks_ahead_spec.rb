# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LooksAhead do
  include GraphqlHelpers

  let_it_be(:the_user) { create(:user) }
  let_it_be(:label_a) { create(:label) }
  let_it_be(:label_b) { create(:label) }
  let_it_be(:issue_a) { create(:issue, author: the_user, labels: [label_a, label_b]) }
  let_it_be(:issue_b) { create(:issue, author: the_user, labels: [label_a]) }
  let_it_be(:issue_c) { create(:issue, author: the_user, labels: [label_b]) }

  # Simplified schema to test lookahead
  let_it_be(:schema) do
    issues_resolver = Class.new(Resolvers::BaseResolver) do
      include LooksAhead

      def resolve_with_lookahead(**args)
        apply_lookahead(object.issues)
      end

      def preloads
        { labels: [:labels] }
      end
    end
    user_resolver = Class.new(Resolvers::BaseResolver) do
      include LooksAhead

      def resolve_with_lookahead(**args)
        relation = UsersFinder.new(current_user, id: args[:id]).execute

        apply_lookahead(relation).first
      end

      def preloads
        { status: [:status] }
      end
    end

    label = Class.new(GraphQL::Schema::Object) do
      graphql_name 'Label'
      field :id, Integer, null: false
    end
    issue = Class.new(GraphQL::Schema::Object) do
      graphql_name 'Issue'
      field :title, String, null: true
      field :labels, label.connection_type, null: true
    end
    user_status = Class.new(GraphQL::Schema::Object) do
      graphql_name 'UserStatus'
      field :id, Integer, null: false
    end
    user = Class.new(GraphQL::Schema::Object) do
      graphql_name 'User'
      field :name, String, null: true
      field :issues, issue.connection_type,
        null: true
      field :issues_with_lookahead, issue.connection_type,
        extras: [:lookahead],
        resolver: issues_resolver,
        null: true
      field :status, user_status,
        null: true
    end

    Class.new(GraphQL::Schema) do
      query(Class.new(GraphQL::Schema::Object) do
        graphql_name 'Query'
        field :find_user, user, resolver: user_resolver, null: true do
          argument :id, Integer, required: true
        end
      end)
    end
  end

  def query(doc = document)
    GraphQL::Query.new(schema,
                       document: doc,
                       context: { current_user: the_user },
                       variables: { id: the_user.id })
  end

  let(:document) do
    GraphQL.parse <<-GRAPHQL
    query($id: Int!){
      findUser(id: $id) {
        name
        issues {
          nodes {
            title
            labels { nodes { id } }
          }
        }
        issuesWithLookahead {
          nodes {
            title
            labels { nodes { id } }
          }
        }
        status { id }
      }
    }
    GRAPHQL
  end

  def run_query(gql_query)
    query(GraphQL.parse(gql_query)).result
  end

  shared_examples 'a working query on the test schema' do
    it 'has a good test setup', :aggregate_failures do
      expected_label_ids = [label_a, label_b].cycle.take(4).map(&:id)
      issue_titles = [issue_a, issue_b, issue_c].map(&:title)

      res = query.result

      expect(res['errors']).to be_blank
      expect(res.dig('data', 'findUser', 'name')).to eq(the_user.name)
      %w(issues issuesWithLookahead).each do |field|
        expect(all_issue_titles(res, field)).to match_array(issue_titles)
        expect(all_label_ids(res, field)).to match_array(expected_label_ids)
      end
    end
  end

  it_behaves_like 'a working query on the test schema'

  it 'preloads labels on issues' do
    mock = Issue.none

    expect_any_instance_of(User).to receive(:issues).twice.and_return(mock)
    expect(mock).to receive(:preload).once.with(:labels)

    query.result
  end

  it 'preloads status on user' do
    mock = double(UserFinder)
    none = User.none

    expect(UsersFinder).to receive(:new).and_return(mock)
    expect(mock).to receive(:execute).and_return(none)
    expect(none).to receive(:preload).with(:status).and_call_original

    query.result
  end

  it 'issues fewer queries than the naive approach' do
    the_user.reload # ensure no attributes are loaded before we begin
    naive = <<-GQL
    query($id: Int!){
      findUser(id: $id) {
        name
        issues {
          nodes {
            labels { nodes { id } }
          }
        }
      }
    }
    GQL
    with_lookahead = <<-GQL
    query($id: Int!){
      findUser(id: $id) {
        name
        issuesWithLookahead {
          nodes {
            labels { nodes { id } }
          }
        }
      }
    }
    GQL

    expect { run_query(with_lookahead) }.to issue_fewer_queries_than { run_query(naive) }
  end

  private

  def all_label_ids(result, field_name)
    result.dig('data', 'findUser', field_name, 'nodes').flat_map do |node|
      node.dig('labels', 'nodes').map { |n| n['id'] }
    end
  end

  def all_issue_titles(result, field_name)
    result.dig('data', 'findUser', field_name, 'nodes').map do |node|
      node['title']
    end
  end
end
