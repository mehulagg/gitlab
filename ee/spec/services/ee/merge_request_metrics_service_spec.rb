# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::MergeRequestMetricsService do
  subject do
    service = MergeRequestMetricsService.new(merge_request.metrics)
    service.merge(event)
    service.merge_request.metrics.reload

    service
  end

  describe '#merge' do
    let(:merge_request) { create(:merge_request, :merged) }
    let(:expected_commit_count) { 21 }
    let(:event) { instance_double('Event', author_id: merge_request.author.id, created_at: Time.current) }

    it 'saves metrics with productivity_data' do
      allow(merge_request).to receive(:commits_count).and_return(expected_commit_count)

      expect { subject }.to change { merge_request.metrics.commits_count }.to(expected_commit_count)
    end

    describe 'storing line counts' do
      let(:expected_added_lines) { 118 }
      let(:expected_removed_lines) { 9 }

      it 'updates `added_lines`' do
        expect { subject }.to change { merge_request.metrics.added_lines }.from(nil).to(expected_added_lines)
      end

      it 'updates `removed_lines`' do
        expect { subject }.to change { merge_request.metrics.removed_lines }.from(nil).to(expected_removed_lines)
      end

      context 'when `store_merge_request_line_metrics` feature flag is disabled' do
        before do
          stub_feature_flags(store_merge_request_line_metrics: false)
        end

        it 'does not update line counts' do
          subject

          expect(merge_request.metrics.added_lines).to be_nil
          expect(merge_request.metrics.removed_lines).to be_nil
        end
      end
    end
  end
end
