# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::JobArtifacts::DestroyBatchService do
  describe '.execute' do
    subject { service.execute }

    let(:service) { described_class.new(Ci::JobArtifact.all, pick_up_at: Time.current) }

    let_it_be(:artifact) { create(:ci_job_artifact) }
    let_it_be(:security_scan) { create(:security_scan, build: artifact.job) }
    let_it_be(:security_finding) { create(:security_finding, scan: security_scan) }

    it 'destroys all expired artifacts' do
      expect { subject }.to change { Ci::JobArtifact.count }.by(-1)
                        .and change { Security::Finding.count }.from(1).to(0)
    end
  end
end
