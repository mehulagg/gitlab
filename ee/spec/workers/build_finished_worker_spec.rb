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

  describe '#revoke_secret_detection_token?' do
    using RSpec::Parameterized::TableSyntax

    where(:dot_com, :token_revocation_enabled, :secret_detection_vulnerability_found, :expected_result) do
      true  | true  | true  | true
      true  | true  | false | false
      true  | false | true  | false
      true  | false | false | false
      false | true  | true  | false
      false | true  | false | false
      false | false | true  | false
      false | false | false | false
    end

    with_them do
      before do
        allow(Gitlab).to receive(:com?) { dot_com }
        stub_application_setting(secret_detection_token_revocation_enabled: token_revocation_enabled)

        allow_next_instance_of(described_class) do |build_finished_worker|
          allow(build_finished_worker).to receive(:secret_detection_vulnerability_found?) { secret_detection_vulnerability_found }
        end
      end

      specify { expect(described_class.new.send(:revoke_secret_detection_token?, build)).to eql(expected_result) }
    end
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

    context 'when token revocation is enabled' do
      before do
        allow_next_instance_of(described_class) do |build_finished_worker|
          allow(build_finished_worker).to receive(:revoke_secret_detection_token?) { true }
        end
      end

      it 'scans security reports for token revocation' do
        expect(ScanSecurityReportSecretsWorker).to receive(:perform_async)

        subject
      end
    end

    context 'when token revocation is disabled' do
      before do
        allow_next_instance_of(described_class) do |build_finished_worker|
          allow(build_finished_worker).to receive(:revoke_secret_detection_token?) { false }
        end
      end

      it 'does not scan security reports for token revocation' do
        expect(ScanSecurityReportSecretsWorker).not_to receive(:perform_async)

        subject
      end
    end
  end
end
