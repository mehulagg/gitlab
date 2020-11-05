# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PaginatedDiffEntity do
  let(:user) { create(:user) }
  let(:request) { double('request', current_user: user) }
  let(:merge_request) { create(:merge_request, :with_diffs) }
  let(:diff_batch) { merge_request.merge_request_diff.diffs_in_batch(2, 3, diff_options: nil) }
  let(:options) do
    {
      request: request,
      merge_request: merge_request,
      pagination_data: diff_batch.pagination_data
    }
  end

  let(:entity) { described_class.new(diff_batch, options) }

  subject { entity.as_json }

  it 'exposes diff_files' do
    expect(subject[:diff_files]).to be_present
  end

  it 'exposes pagination data' do
    expect(subject[:pagination]).to eq(
      current_page: 2,
      next_page: 3,
      next_page_href: "/#{merge_request.project.full_path}/-/merge_requests/#{merge_request.iid}/diffs_batch.json?page=3",
      total_pages: 7
    )
  end

  context 'when there are conflicts' do
    let(:conflicts) { double(files: []) }

    before do
      allow_next_instance_of(MergeRequests::Conflicts::ListService) do |instance|
        allow(instance).to receive(:conflicts).and_return(conflicts)
      end
    end

    it 'lines are parsed with passed conflicts' do
      expect(Gitlab::Git::Conflict::LineParser).to(
        receive(:new).exactly(3).times.with(anything, conflicts).and_call_original
      )

      subject
    end

    context 'when diff lines should not be highlighted' do
      before do
        allow(merge_request).to receive(:highlight_diff_conflicts?).and_return(false)
      end

      it 'conflicts has no impact on line parsing' do
        expect(Gitlab::Git::Conflict::LineParser).not_to receive(:new)

        subject
      end
    end
  end
end
