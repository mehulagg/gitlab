# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::StoreReportService, '#execute' do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:user) { create(:user) }

  let(:artifact) { create(:ee_ci_job_artifact, trait) }
  let(:report_type) { artifact.file_type }
  let(:project) { artifact.project }
  let(:pipeline) { artifact.job.pipeline }
  let(:report) { pipeline.security_reports.get_report(report_type.to_s, artifact) }

  subject { described_class.new(pipeline, report).execute }

  where(:vulnerability_finding_signatures_enabled, :optimize_sql_query_for_security_report_ff) do
    true  | true
    true  | false
    false | true
    false | false
  end

  with_them do
    before do
      stub_feature_flags(vulnerability_finding_tracking_signatures: vulnerability_finding_signatures_enabled)
      stub_feature_flags(optimize_sql_query_for_security_report: optimize_sql_query_for_security_report_ff)
      stub_licensed_features(
        sast: true,
        dependency_scanning: true,
        container_scanning: true,
        security_dashboard: true,
        vulnerability_finding_signatures: vulnerability_finding_signatures_enabled
      )
      allow(Security::AutoFixWorker).to receive(:perform_async)
    end

    context 'without existing data' do
      before(:all) do
        checksum = 'f00bc6261fa512f0960b7fc3bfcce7fb31997cf32b96fa647bed5668b2c77fee'
        create(:vulnerabilities_remediation, checksum: checksum)
      end

      before do
        project.add_developer(user)
        allow(pipeline).to receive(:user).and_return(user)
      end

      context 'for different security reports' do
        where(:case_name, :trait, :scanners, :identifiers, :findings, :finding_identifiers, :finding_pipelines, :remediations, :signatures) do
          'with SAST report'                | :sast                            | 1 | 6  | 5  | 7  | 5  | 0 | 2
          'with exceeding identifiers'      | :with_exceeding_identifiers      | 1 | 20 | 1  | 20 | 1  | 0 | 0
          'with Dependency Scanning report' | :dependency_scanning_remediation | 1 | 3  | 2  | 3  | 2  | 1 | 0
          'with Container Scanning report'  | :container_scanning              | 1 | 8  | 8  | 8  | 8  | 0 | 0
        end

        with_them do
          it 'inserts all scanners' do
            expect { subject }.to change { Vulnerabilities::Scanner.count }.by(scanners)
          end

          it 'inserts all identifiers' do
            expect { subject }.to change { Vulnerabilities::Identifier.count }.by(identifiers)
          end

          it 'inserts all findings' do
            expect { subject }.to change { Vulnerabilities::Finding.count }.by(findings)
          end

          it 'inserts all finding identifiers (join model)' do
            expect { subject }.to change { Vulnerabilities::FindingIdentifier.count }.by(finding_identifiers)
          end

          it 'inserts all finding pipelines (join model)' do
            expect { subject }.to change { Vulnerabilities::FindingPipeline.count }.by(finding_pipelines)
          end

          it 'inserts all remediations' do
            expect { subject }.to change { project.vulnerability_remediations.count }.by(remediations)
          end

          it 'inserts all vulnerabilities' do
            expect { subject }.to change { Vulnerability.count }.by(findings)
          end

          it 'inserts all signatures' do
            signatures_count = vulnerability_finding_signatures_enabled ? signatures : 0
            expect { subject }.to change { Vulnerabilities::FindingSignature.count }.by(signatures_count)
          end
        end
      end

      context 'when there is an exception' do
        let(:trait) { :sast }

        subject { described_class.new(pipeline, report) }

        it 'does not insert any scanner' do
          allow(Vulnerabilities::Scanner).to receive(:insert_all).with(anything).and_raise(StandardError)
          expect { subject.send(:update_vulnerability_scanners!, report.findings) }.to change { Vulnerabilities::Scanner.count }.by(0)
        end
      end

      context 'when N+1 database queries have been removed' do
        let(:trait) { :sast }
        let(:bandit_scanner) { build(:ci_reports_security_scanner, external_id: 'bandit', name: 'Bandit') }

        subject { described_class.new(pipeline, report) }

        it "avoids N+1 database queries for updating vulnerability scanners", :use_sql_query_cache do
          report.add_scanner(bandit_scanner)

          control_count = ActiveRecord::QueryRecorder.new(skip_cached: false) { subject.send(:update_vulnerability_scanners!, report.findings) }.count

          5.times { report.add_finding(build(:ci_reports_security_finding, scanner: bandit_scanner)) }

          expect {  described_class.new(pipeline, report).send(:update_vulnerability_scanners!, report.findings) }.not_to exceed_query_limit(control_count)
        end
      end

      context 'when report data includes all raw_metadata' do
        let(:trait) { :dependency_scanning_remediation }

        it 'inserts top level finding data', :aggregate_failures do
          subject

          finding = Vulnerabilities::Finding.last
          finding.raw_metadata = nil

          expect(finding.metadata).to be_blank
          expect(finding.cve).not_to be_nil
          expect(finding.description).not_to be_nil
          expect(finding.location).not_to be_nil
          expect(finding.message).not_to be_nil
          expect(finding.solution).not_to be_nil
        end
      end

      context 'invalid data' do
        let(:artifact) { create(:ee_ci_job_artifact, :sast) }
        let(:finding_without_name) { build(:ci_reports_security_finding, name: nil) }
        let(:report) { Gitlab::Ci::Reports::Security::Report.new('container_scanning', nil, nil) }

        before do
          allow(Gitlab::ErrorTracking).to receive(:track_and_raise_exception).and_call_original
          report.add_finding(finding_without_name)
        end

        it 'raises invalid record error' do
          expect { subject.execute }.to raise_error(ActiveRecord::RecordInvalid)
        end

        it 'reports the error correctly' do
          expected_params = finding_without_name.to_hash.dig(:raw_metadata)
          expect { subject.execute }.to raise_error { |error|
            expect(Gitlab::ErrorTracking).to have_received(:track_and_raise_exception).with(error, create_params: expected_params)
          }
        end
      end
    end

    context 'with existing data from previous pipeline' do
      let(:finding_identifier_fingerprint) do
        build(:ci_reports_security_identifier, external_id: "CIPHER_INTEGRITY").fingerprint
      end

      let(:scanner) { build(:vulnerabilities_scanner, project: project, external_id: 'find_sec_bugs', name: 'Find Security Bugs') }
      let(:identifier) { build(:vulnerabilities_identifier, project: project, fingerprint: finding_identifier_fingerprint) }
      let(:different_identifier) { build(:vulnerabilities_identifier, project: project) }
      let!(:new_artifact) { create(:ee_ci_job_artifact, :sast, job: new_build) }
      let(:new_build) { create(:ci_build, pipeline: new_pipeline) }
      let(:new_pipeline) { create(:ci_pipeline, project: project) }
      let(:new_report) { new_pipeline.security_reports.get_report(report_type.to_s, artifact) }
      let(:existing_signature) { create(:vulnerabilities_finding_signature, finding: finding) }

      let(:trait) { :sast }

      let(:finding_location_fingerprint) do
        build(
          :ci_reports_security_locations_sast,
          file_path: "groovy/src/main/java/com/gitlab/security_products/tests/App.groovy",
          start_line: "29",
          end_line: "29"
        ).fingerprint
      end

      let!(:finding) do
        created_finding = create(:vulnerabilities_finding,
          pipelines: [pipeline],
          identifiers: [identifier],
          primary_identifier: identifier,
          scanner: scanner,
          project: project,
          uuid: "e5388f40-18f5-566d-95c6-d64c6f46a00a",
          location_fingerprint: finding_location_fingerprint)

        existing_finding = report.findings.find { |f| f.location.fingerprint == created_finding.location_fingerprint }

        create(:vulnerabilities_finding_signature,
               finding: created_finding,
               algorithm_type: existing_finding.signatures.first.algorithm_type,
               signature_sha: existing_finding.signatures.first.signature_sha)

        created_finding
      end

      let!(:vulnerability) { create(:vulnerability, findings: [finding], project: project) }

      let(:desired_uuid) do
        Security::VulnerabilityUUID.generate(
          report_type: finding.report_type,
          primary_identifier_fingerprint: finding.primary_identifier.fingerprint,
          location_fingerprint: finding.location_fingerprint,
          project_id: finding.project_id
        )
      end

      let!(:finding_with_uuidv5) do
        create(:vulnerabilities_finding,
               pipelines: [pipeline],
               identifiers: [different_identifier],
               primary_identifier: different_identifier,
               scanner: scanner,
               project: project,
               location_fingerprint: '34661e23abcf78ff80dfcc89d0700437612e3f88')
      end

      let!(:vulnerability_with_uuid5) { create(:vulnerability, findings: [finding_with_uuidv5], project: project) }

      before do
        project.add_developer(user)
        allow(new_pipeline).to receive(:user).and_return(user)
      end

      subject { described_class.new(new_pipeline, new_report).execute }

      it 'does not change existing UUIDv5' do
        expect { subject }.not_to change(finding_with_uuidv5, :uuid)
      end

      it 'updates UUIDv4 to UUIDv5' do
        finding.uuid = '00000000-1111-2222-3333-444444444444'
        finding.save!

        # this report_finding should be used to update the finding's uuid
        report_finding = new_report.findings.find { |f| f.location.fingerprint == '0e7d0291d912f56880e39d4fbd80d99dd5d327ba' }
        allow(report_finding).to receive(:uuid).and_return(desired_uuid)
        report_finding.signatures.pop

        subject

        expect(finding.reload.uuid).to eq(desired_uuid)
      end

      it 'reuses existing scanner' do
        expect { subject }.not_to change { Vulnerabilities::Scanner.count }
      end

      it 'inserts only new identifiers and reuse existing ones' do
        expect { subject }.to change { Vulnerabilities::Identifier.count }.by(5)
      end

      it 'inserts only new findings and reuse existing ones' do
        expect { subject }.to change { Vulnerabilities::Finding.count }.by(4)
      end

      it 'inserts all finding pipelines (join model) for this new pipeline' do
        expect { subject }.to change { Vulnerabilities::FindingPipeline.where(pipeline: new_pipeline).count }.by(5)
      end

      it 'inserts new vulnerabilities with data from findings from this new pipeline' do
        expect { subject }.to change { Vulnerability.count }.by(4)
      end

      it 'updates existing findings with new data' do
        subject

        expect(finding.reload).to have_attributes(severity: 'medium', name: 'Cipher with no integrity')
      end

      it 'updates signatures to match new values' do
        next unless vulnerability_finding_signatures_enabled

        expect(finding.signatures.count).to eq(1)
        expect(finding.signatures.first.algorithm_type).to eq('hash')

        existing_signature = finding.signatures.first

        subject

        finding.reload
        existing_signature.reload

        expect(finding.signatures.count).to eq(2)
        signature_algs = finding.signatures.sort_by(&:priority).map(&:algorithm_type)
        expect(signature_algs).to eq(%w[hash scope_offset])

        # check that the existing hash signature was updated/reused
        expect(existing_signature.id).to eq(finding.signatures.find(&:algorithm_hash?).id)
      end

      it 'updates existing vulnerability with new data' do
        subject

        expect(vulnerability.reload).to have_attributes(severity: 'medium', title: 'Cipher with no integrity', title_html: 'Cipher with no integrity')
      end

      context 'when the existing vulnerability is resolved with the latest report' do
        let!(:existing_vulnerability) { create(:vulnerability, report_type: report_type, project: project) }

        it 'marks the vulnerability as resolved on default branch' do
          expect { subject }.to change { existing_vulnerability.reload.resolved_on_default_branch }.from(false).to(true)
        end
      end

      context 'when the existing resolved vulnerability is discovered again on the latest report' do
        before do
          vulnerability.update_column(:resolved_on_default_branch, true)
        end

        it 'marks the vulnerability as not resolved on default branch' do
          expect { subject }.to change { vulnerability.reload.resolved_on_default_branch }.from(true).to(false)
        end
      end

      context 'when the finding is not valid' do
        before do
          allow(Gitlab::AppLogger).to receive(:warn)
          allow_next_instance_of(::Gitlab::Ci::Reports::Security::Finding) do |finding|
            allow(finding).to receive(:valid?).and_return(false)
          end
        end

        it 'does not create a new finding' do
          expect { subject }.not_to change { Vulnerabilities::Finding.count }
        end

        it 'does not raise an error' do
          expect { subject }.not_to raise_error
        end

        it 'puts a warning log' do
          subject

          expect(Gitlab::AppLogger).to have_received(:warn).exactly(new_report.findings.length).times
        end
      end

      context 'vulnerability issue link' do
        context 'when there is no assoiciated issue feedback with finding' do
          it 'does not insert issue links from the new pipeline' do
            expect { subject }.to change { Vulnerabilities::IssueLink.count }.by(0)
          end
        end

        context 'when there is an associated issue feedback with finding' do
          let(:issue) { create(:issue, project: project) }
          let!(:issue_feedback) do
            create(
              :vulnerability_feedback,
              :sast,
              :issue,
              issue: issue,
              project: project,
              project_fingerprint: new_report.findings.first.project_fingerprint
            )
          end

          it 'inserts issue links from the new pipeline' do
            expect { subject }.to change { Vulnerabilities::IssueLink.count }.by(1)
          end

          it 'the issue link is valid' do
            subject

            finding = Vulnerabilities::Finding.find_by(uuid: new_report.findings.first.uuid)
            vulnerability_id = finding.vulnerability_id
            issue_id = issue.id
            issue_link = Vulnerabilities::IssueLink.find_by(
              vulnerability_id: vulnerability_id,
              issue_id: issue_id
            )

            expect(issue_link).not_to be_nil
          end
        end
      end
    end

    context 'with existing data from same pipeline' do
      let!(:finding) { create(:vulnerabilities_finding, project: project, pipelines: [pipeline]) }
      let(:trait) { :sast }

      it 'skips report' do
        expect(subject).to eq({
          status: :error,
          message: "sast report already stored for this pipeline, skipping..."
        })
      end
    end

    context 'start auto_fix' do
      before do
        stub_licensed_features(vulnerability_auto_fix: true)
      end

      context 'with auto fix supported report type' do
        let(:trait) { :dependency_scanning }

        context 'when auto fix enabled' do
          it 'start auto fix worker' do
            expect(Security::AutoFixWorker).to receive(:perform_async).with(pipeline.id)

            subject
          end
        end

        context 'when auto fix disabled' do
          context 'when feature flag is disabled' do
            before do
              stub_feature_flags(security_auto_fix: false)
            end

            it 'does not start auto fix worker' do
              expect(Security::AutoFixWorker).not_to receive(:perform_async)

              subject
            end
          end

          context 'when auto fix feature is disabled' do
            before do
              project.security_setting.update_column(:auto_fix_dependency_scanning, false)
            end

            it 'does not start auto fix worker' do
              expect(Security::AutoFixWorker).not_to receive(:perform_async)

              subject
            end
          end

          context 'when licensed feature is unavailable' do
            before do
              stub_licensed_features(vulnerability_auto_fix: false)
            end

            it 'does not start auto fix worker' do
              expect(Security::AutoFixWorker).not_to receive(:perform_async)

              subject
            end
          end

          context 'when security setting is not created' do
            before do
              project.security_setting.destroy!
              project.reload
            end

            it 'does not start auto fix worker' do
              expect(Security::AutoFixWorker).not_to receive(:perform_async)
              expect(subject[:status]).to eq(:success)
            end
          end
        end
      end

      context 'with auto fix not supported report type' do
        let(:trait) { :sast }

        before do
          stub_licensed_features(vulnerability_auto_fix: true)
        end

        it 'does not start auto fix worker' do
          expect(Security::AutoFixWorker).not_to receive(:perform_async)

          subject
        end
      end
    end
  end
end
