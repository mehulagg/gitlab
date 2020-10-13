# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::MergeRequestMetricsRefresh do
  subject { calculator_class.new(merge_request) }

  around do |example|
    Timecop.freeze { example.run }
  end

  let(:calculator_class) do
    Class.new do
      include Analytics::MergeRequestMetricsRefresh

      def self.name
        'MyTestClass'
      end

      def metric_already_present?(metrics)
        metrics.first_comment_at
      end

      def update_metric!(metrics)
        metrics.first_comment_at = Time.zone.now
      end
    end
  end

  let!(:merge_request) { create(:merge_request) }

  describe '#execute' do
    it 'updates metric via update_metric! method' do
      expect { subject.execute }.to change { merge_request.metrics.first_comment_at }.to(be_like_time(Time.zone.now))
    end

    context 'when metric is already present' do
      let(:first_comment_at) { 1.day.ago }

      before do
        merge_request.metrics.update!(first_comment_at: first_comment_at)
      end

      it 'does not update metric' do
        subject.execute

        expect(merge_request.metrics.reload.first_comment_at).to be_like_time(first_comment_at)
      end

      it 'updates metric when forced' do
        expect { subject.execute(force: true) }.to change { merge_request.metrics.first_comment_at }.to(be_like_time(Time.zone.now))
      end
    end
  end

  describe '#execute_async' do
    it 'schedules CodeReviewMetricsWorker with params' do
      expect(Analytics::CodeReviewMetricsWorker)
        .to receive(:perform_async)
              .with('MyTestClass', merge_request.id, force: true)

      subject.execute_async(force: true)
    end
  end
end
