# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'getting epics information' do
  include GraphqlHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }

  before do
    group.add_maintainer(user)
    stub_licensed_features(epics: true)
  end

  describe 'query for epics which start with an iid' do
    let_it_be(:epic1) { create(:epic, group: group, iid: 11) }
    let_it_be(:epic2) { create(:epic, group: group, iid: 22) }
    let_it_be(:epic3) { create(:epic, group: group, iid: 2223) }
    let_it_be(:epic4) { create(:epic, group: group, iid: 29) }

    context 'when a valid iidStartsWith query is provided' do
      it 'returns the expected epics' do
        query_epics_which_start_with_iid('22')

        expect_epics_response(epic2, epic3)
      end
    end

    context 'when invalid iidStartsWith query is provided' do
      it 'fails with negative number' do
        query_epics_which_start_with_iid('-2')

        expect(graphql_errors).to include(a_hash_including('message' => 'Invalid `iidStartsWith` query'))
      end

      it 'fails with string' do
        query_epics_which_start_with_iid('foo')

        expect(graphql_errors).to include(a_hash_including('message' => 'Invalid `iidStartsWith` query'))
      end

      it 'fails if query contains line breaks' do
        query_epics_which_start_with_iid('2\nfoo')

        expect(graphql_errors).to include(a_hash_including('message' => 'Invalid `iidStartsWith` query'))
      end
    end

    def query_epics_which_start_with_iid(iid)
      post_graphql(epics_query(group, 'iidStartsWith', iid), current_user: user)
    end
  end

  describe 'query for epics by time frame' do
    let_it_be(:epic1) { create(:epic, group: group, state: :opened, start_date: "2019-08-13", end_date: "2019-08-20") }
    let_it_be(:epic2) { create(:epic, group: group, state: :closed, start_date: "2019-08-13", end_date: "2019-08-21") }
    let_it_be(:epic3) { create(:epic, group: group, state: :closed, start_date: "2019-08-22", end_date: "2019-08-26") }
    let_it_be(:epic4) { create(:epic, group: group, state: :closed, start_date: "2019-08-10", end_date: "2019-08-12") }

    context 'when start_date and end_date are present' do
      it 'returns epics within timeframe' do
        post_graphql(epics_query_by_hash(group, "timeframe: {#{field_query({ 'start' => '2019-08-13', 'end' => '2019-08-21' })}}"), current_user: user)

        expect_epics_response(epic1, epic2)
      end
    end

    context 'when only start is present' do
      it 'raises error' do
        post_graphql(epics_query_by_hash(group, "timeframe: {#{field_query({ 'start' => '2019-08-13' })}}"), current_user: user)

        expect(graphql_errors).to include(a_hash_including('message' => "Argument 'end' on InputObject 'Timeframe' is required. Expected type Date!"))
      end
    end

    context 'when only end is present' do
      it 'raises error' do
        post_graphql(epics_query_by_hash(group, "timeframe: {#{field_query({ 'end' => '2019-08-21' })}}"), current_user: user)

        expect(graphql_errors).to include(a_hash_including('message' => "Argument 'start' on InputObject 'Timeframe' is required. Expected type Date!"))
      end
    end
  end

  context 'query for epics with events' do
    let_it_be(:epic) { create(:epic, group: group) }

    it 'can lookahead to prevent N+1 queries' do
      create_list(:event, 10, :created, target: epic, group: group)

      control_count = ActiveRecord::QueryRecorder.new(skip_cached: false) do
        query_epics_with_events(1)
      end.count

      events = graphql_dig_at(graphql_data, :group, :epics, :nodes, :events, :nodes)
      expect(events.count).to eq(1)

      expect do
        query_epics_with_events(10)
      end.not_to exceed_all_query_limit(control_count)

      data = graphql_data(fresh_response_data)
      events = graphql_dig_at(data, :group, :epics, :nodes, :events, :nodes)
      expect(events.count).to eq(10)
    end
  end

  def query_epics_with_events(number)
    epics_field = <<~NODE
      epics {
        nodes {
          id
          events(first: #{number}) {
            nodes {
              id
            }
          }
        }
      }
    NODE

    post_graphql(
      graphql_query_for('group', { 'fullPath' => group.full_path }, epics_field),
      current_user: user
    )
  end

  def epics_query(group, field, value)
    epics_query_by_hash(group, field_query(field => value))
  end

  def epics_query_by_hash(group, query)
    <<~QUERY
      query {
        group(fullPath: "#{group.full_path}") {
          id,
          epics(#{query}) {
            nodes {
              id
            }
          }
        }
      }
    QUERY
  end

  def field_query(args)
    args.map { |key, value| "#{key}:\"#{value}\"" }.join(',')
  end

  def expect_epics_response(*epics)
    actual_epics = graphql_data['group']['epics']['nodes'].map { |epic| epic['id'] }
    expected_epics = epics.map { |epic| epic.to_global_id.to_s }

    expect(actual_epics).to contain_exactly(*expected_epics)
    expect(graphql_errors).to be_nil
  end
end
