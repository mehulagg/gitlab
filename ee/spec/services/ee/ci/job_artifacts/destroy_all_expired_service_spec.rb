# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::JobArtifacts::DestroyAllExpiredService, :clean_gitlab_redis_shared_state do
  include ExclusiveLeaseHelpers

  describe '.execute' do
    subject { service.execute }

    let(:service) { described_class.new }

    let_it_be(:artifact) { create(:ci_job_artifact, expire_at: 1.day.ago) }
    let_it_be(:security_scan) { create(:security_scan, build: artifact.job) }
    let_it_be(:security_finding) { create(:security_finding, scan: security_scan) }

    before(:all) do
      artifact.job.pipeline.unlocked!
    end

    context 'when artifact is expired' do
      context 'when artifact is not locked' do
        it 'destroys job artifact and the security finding' do
          expect { subject }.to change { Ci::JobArtifact.count }.by(-1)
                            .and change { Security::Finding.count }.from(1).to(0)
        end
      end

      context 'when artifact is locked' do
        before do
          artifact.job.pipeline.reload.artifacts_locked!
        end

        it 'does not destroy job artifact' do
          expect { subject }.to not_change { Ci::JobArtifact.count }
                            .and not_change { Security::Finding.count }.from(1)
        end
      end
    end

    context 'when artifact is not expired' do
      before do
        artifact.update_column(:expire_at, 1.day.since)
      end

      it 'does not destroy expired job artifacts' do
        expect { subject }.to not_change { Ci::JobArtifact.count }
                          .and not_change { Security::Finding.count }.from(1)
      end
    end

    context 'when artifact is permanent' do
      before do
        artifact.update_column(:expire_at, nil)
      end

      it 'does not destroy expired job artifacts' do
        expect { subject }.to not_change { Ci::JobArtifact.count }
                          .and not_change { Security::Finding.count }.from(1)
      end
    end

    context 'when failed to destroy artifact' do
      before do
        stub_const('Ci::JobArtifacts::DestroyAllExpiredService::LOOP_LIMIT', 10)
        expect(Ci::DeletedObject)
          .to receive(:bulk_import)
          .once
          .and_raise(ActiveRecord::RecordNotDestroyed)
      end

      it 'raises an exception and stop destroying' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotDestroyed)
                          .and not_change { Security::Finding.count }.from(1)
      end
    end

    context 'when there are artifacts more than batch sizes' do
      before do
        stub_const('Ci::JobArtifacts::DestroyAllExpiredService::BATCH_SIZE', 1)

        second_artifact.job.pipeline.unlocked!
      end

      let!(:second_artifact) { create(:ci_job_artifact, expire_at: 1.day.ago) }
      let!(:second_security_scan) { create(:security_scan, build: second_artifact.job) }
      let!(:second_security_finding) { create(:security_finding, scan: second_security_scan) }

      it 'destroys all expired artifacts' do
        expect { subject }.to change { Ci::JobArtifact.count }.by(-2)
                          .and change { Security::Finding.count }.from(2).to(0)
      end
    end

    context 'when some artifacts are locked' do
      before do
        pipeline = create(:ci_pipeline, locked: :artifacts_locked)
        job = create(:ci_build, pipeline: pipeline)
        create(:ci_job_artifact, expire_at: 1.day.ago, job: job)
        security_scan = create(:security_scan, build: job)
        create(:security_finding, scan: security_scan)
      end

      it 'destroys only unlocked artifacts' do
        expect { subject }.to change { Ci::JobArtifact.count }.by(-1)
                          .and change { Security::Finding.count }.from(2).to(1)
      end
    end
  end
end
