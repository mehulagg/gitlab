# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::API::Entities::Analytics::CodeReview::MergeRequest do
  subject(:entity_representation) { described_class.new(merge_request).as_json }

  let(:merge_request) do
    create(:merge_request, :with_productivity_metrics,
           milestone: milestone,
           source_project: project,
           metrics_data: { first_comment_at: 1.day.ago, merged_at: 1.hour.ago }
    )
  end

  let(:project) { create :project, :repository }
  let(:milestone) { create(:milestone, project: project) }
  let!(:note) { create(:note_on_merge_request, project: project, noteable: merge_request) }

  it 'exposes mr attributes' do
    expect(entity_representation).to include(
      {
        id: merge_request.id,
        iid: merge_request.iid,
        title: merge_request.title,
        created_at: merge_request.created_at,
        notes_count: 1,
        review_time: 23,
        diff_stats: {
          additions: 118,
          deletions: 9,
          total: 127,
          commits_count: 29
        }
      }
    )
    expect(entity_representation[:milestone][:title]).to eq milestone.title
    expect(entity_representation[:author][:id]).to eq merge_request.author.id
  end
end
