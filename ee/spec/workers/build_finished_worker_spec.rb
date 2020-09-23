# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BuildFinishedWorker do
  let(:ci_runner) { create(:ci_runner) }
  let(:build) { create(:ee_ci_build, :success, runner: ci_runner) }
  let(:project) { build.project }
  let(:namespace) { project.shared_runners_limit_namespace }

  subject do
    described_class.new.perform(build.id)
  end

  def namespace_stats
    namespace.namespace_statistics || namespace.create_namespace_statistics
  end

  def project_stats
    project.statistics || project.create_statistics(namespace: project.namespace)
  end

  describe '#perform' do
    context 'when on .com' do
      before do
        allow(Gitlab).to receive(:com?).and_return(true)
        allow_any_instance_of(EE::Project).to receive(:shared_runners_minutes_limit_enabled?).and_return(true)
      end

      it 'updates the project stats' do
        expect { subject }.to change { project_stats.reload.shared_runners_seconds }
      end

      it 'updates the namespace stats' do
        expect { subject }.to change { namespace_stats.reload.shared_runners_seconds }
      end

      it 'notifies the owners of Groups' do
        namespace.update_attribute(:shared_runners_minutes_limit, 2000)
        namespace_stats.update_attribute(:shared_runners_seconds, 2100 * 60)

        expect(CiMinutesUsageMailer).to receive(:notify).once.with(namespace, [namespace.owner.email]).and_return(spy)

        subject
      end

      it 'stores security scans' do
        expect(StoreSecurityScansWorker).to receive(:perform_async)

        subject
      end
    end

    context 'when not on .com' do
      before do
        allow(Gitlab).to receive(:com?).and_return(false)
      end

      it 'does not notify the owners of Groups' do
        expect(::Ci::Minutes::EmailNotificationService).not_to receive(:new)

        subject
      end
    end

    it 'processes requirements reports' do
      expect(RequirementsManagement::ProcessRequirementsReportsWorker).to receive(:perform_async)

      subject
    end
  end
end
