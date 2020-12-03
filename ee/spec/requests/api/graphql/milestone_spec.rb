# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Querying a Milestone' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:milestone) { create(:milestone, project: project, start_date: '2020-01-01', due_date: '2020-01-15') }

  let(:query) do
    graphql_query_for('milestone', { id: milestone.to_global_id.to_s }, fields)
  end

  subject { graphql_data['milestone'] }

  before_all do
    project.add_guest(current_user)
  end

  context 'burnupTimeSeries' do
    let(:fields) do
      <<~FIELDS
      report {
        burnupTimeSeries {
          date
          scopeCount
          scopeWeight
          completedCount
          completedWeight
        }
      }
      FIELDS
    end

    let_it_be(:issue) { create(:issue, project: project) }

    before_all do
      create(:resource_milestone_event, issue: issue, milestone: milestone, action: :add, created_at: '2020-01-05')
    end

    context 'with insufficient license' do
      before do
        stub_licensed_features(milestone_charts: false)
      end

      it 'returns an error' do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to include(a_hash_including('message' => 'Milestone does not support burnup charts'))
      end
    end

    context 'with correct license' do
      before do
        stub_licensed_features(milestone_charts: true, issue_weights: true)
      end

      it 'returns burnup chart data' do
        post_graphql(query, current_user: current_user)

        expect(subject).to eq({
          'report' => {
            'burnupTimeSeries' => [
              {
                'date' => '2020-01-05',
                'scopeCount' => 1,
                'scopeWeight' => 0,
                'completedCount' => 0,
                'completedWeight' => 0
              }
            ]
          }
        })
      end
    end
  end
end
