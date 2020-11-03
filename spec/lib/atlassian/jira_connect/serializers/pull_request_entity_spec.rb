# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Atlassian::JiraConnect::Serializers::PullRequestEntity do
  let_it_be(:project) { create_default(:project, :repository) }
  let_it_be(:merge_requests) { create_list(:merge_request, 2, :unique_branches) }
  let_it_be(:notes) { create_list(:note, 2, system: false, noteable: merge_requests.first) }

  subject { described_class.represent(merge_requests).as_json }

  it 'has exposes commentCount' do
    expect(subject.first[:commentCount]).to eq(2)
  end

  context 'with preloaded_user_notes_count' do
    let(:preloaded_user_notes_count) { merge_requests.map { |merge_request| [merge_request.id, 1] }.to_h }

    subject { described_class.represent(merge_requests, preloaded_user_notes_count: preloaded_user_notes_count).as_json }

    it 'avoids N+1 database queries' do
      control_count = ActiveRecord::QueryRecorder.new { described_class.represent(merge_requests).as_json }.count

      merge_requests << create(:merge_request, :unique_branches)

      expect { subject }.not_to exceed_query_limit(control_count)
    end

    it 'uses counts from preloaded_user_notes_count' do
      expect(subject.map { |entity| entity[:commentCount] }).to match_array([1, 1, 1])
    end

    context 'when count is missing for some MRs' do
      let(:preloaded_user_notes_count) { [[merge_requests.last.id, 1]].to_h }

      it 'uses 0 as default when count for the MR is not available' do
        expect(subject.map { |entity| entity[:commentCount] }).to match_array([0, 0, 1])
      end
    end
  end
end
