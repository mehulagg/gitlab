# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Insights::Reducers::LabelCountPerPeriodReducer do
  include_context 'Insights issues reducer context'

  def find_issuables(project, query)
    Gitlab::Insights::Finders::IssuableFinder.new(project, nil, query: query).find
  end

  def reduce(issuable_relation, period, labels)
    described_class.reduce(issuable_relation, period: period, period_limit: 5, labels: labels)
  end

  let(:query) do
    {
      state: 'opened',
      issuable_type: 'issue',
      filter_labels: [label_bug.title],
      collection_labels: [label_manage.title, label_plan.title],
      group_by: 'month',
      period_limit: 5
    }
  end

  let(:issuable_relation) { find_issuables(project, query) }

  subject { reduce(issuable_relation, query[:group_by], query[:collection_labels]) }

  let(:expected) do
    {
      'January 2019' => {
        label_manage.title => 0,
        label_plan.title => 0,
        Gitlab::Insights::UNCATEGORIZED => 1
      },
      'February 2019' => {
        label_manage.title => 0,
        label_plan.title => 0,
        Gitlab::Insights::UNCATEGORIZED => 0
      },
      'March 2019' => {
        label_manage.title => 1,
        label_plan.title => 0,
        Gitlab::Insights::UNCATEGORIZED => 0
      },
      'April 2019' => {
        label_manage.title => 0,
        label_plan.title => 1,
        Gitlab::Insights::UNCATEGORIZED => 0
      },
      'May 2019' => {
        label_manage.title => 0,
        label_plan.title => 0,
        Gitlab::Insights::UNCATEGORIZED => 0
      }
    }
  end

  it 'returns issuables with only the needed fields' do
    expect(subject).to eq(expected)
  end

  it 'avoids N + 1 queries' do
    control_queries = ActiveRecord::QueryRecorder.new { subject }
    create(:labeled_issue, :opened, created_at: Time.utc(2019, 2, 5), labels: [label_bug], project: project)

    expect { reduce(find_issuables(project, query), query[:group_by], query[:collection_labels]) }.not_to exceed_query_limit(control_queries)
  end
end
