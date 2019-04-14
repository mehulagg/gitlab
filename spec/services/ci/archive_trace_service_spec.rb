# frozen_string_literal: true

require 'spec_helper'

describe Ci::ArchiveTraceService, '#execute' do
  subject { described_class.new.execute(job) }

  context 'when job is finished' do
    let(:job) { create(:ci_build, :success, :trace_live) }

    it 'creates an archived trace' do
      expect { subject }.not_to raise_error

      expect(job.reload.job_artifacts_trace).to be_exist
    end

    context 'when trace is already archived' do
      let!(:job) { create(:ci_build, :success, :trace_artifact) }

      it 'ignores an exception' do
        expect { subject }.not_to raise_error
      end

      it 'does not create an archived trace' do
        expect { subject }.not_to change { Ci::JobArtifact.trace.count }
      end
    end
  end

  context 'when job is running' do
    let(:job) { create(:ci_build, :running, :trace_live) }

    it 'increments Prometheus counter, sends crash report to Sentry and ignore an error for continuing to archive' do
      expect(Gitlab::Sentry)
        .to receive(:track_exception)
        .with(::Gitlab::Ci::Trace::ArchiveError,
              issue_url: 'https://gitlab.com/gitlab-org/gitlab-ce/issues/51502',
              extra: { job_id: job.id } ).once

      expect(Rails.logger)
        .to receive(:error)
        .with("Failed to archive trace. id: #{job.id} message: Job is not finished yet")
        .and_call_original

      expect(Gitlab::Metrics)
        .to receive(:counter)
        .with(:job_trace_archive_failed_total, "Counter of failed attempts of trace archiving")
        .and_call_original

      expect { subject }.not_to raise_error
    end
  end
end
