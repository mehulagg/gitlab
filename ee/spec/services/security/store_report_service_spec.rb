# frozen_string_literal: true

require 'spec_helper'

UUID_REGEXP = Regexp.new("^([0-9a-f]{8})-([0-9a-f]{4})-([0-9a-f]{4})-" \
                         "([0-9a-f]{2})([0-9a-f]{2})-([0-9a-f]{12})$").freeze

RSpec::Matchers.define :be_uuid_v5 do
  match do |string|
    expect(string).to be_a(String)

    uuid_components = string.downcase.scan(UUID_REGEXP).first
    time_hi_and_version = uuid_components[2].to_i(16)
    (time_hi_and_version >> 12) == 5
  end
end

RSpec.describe Security::StoreReportService, '#execute' do
  let_it_be(:user) { create(:user) }
  let(:artifact) { create(:ee_ci_job_artifact, trait) }
  let(:report_type) { artifact.file_type }
  let(:project) { artifact.project }
  let(:pipeline) { artifact.job.pipeline }
  let(:report) { pipeline.security_reports.get_report(report_type.to_s, artifact) }

  before do
    stub_licensed_features(sast: true, dependency_scanning: true, container_scanning: true, security_dashboard: true)
  end

  subject { described_class.new(pipeline, report).execute }

  context 'without existing data' do
    before do
      project.add_developer(user)
      allow(pipeline).to receive(:user).and_return(user)
    end

    using RSpec::Parameterized::TableSyntax

    where(:case_name, :trait, :scanners, :identifiers, :findings, :finding_identifiers, :finding_pipelines, :finding_links) do
      'with SAST report'                | :sast                       | 3 | 17 | 33 | 39 | 33 | 0
      'with exceeding identifiers'      | :with_exceeding_identifiers | 1 | 20 | 1  | 20 | 1  | 0
      'with Dependency Scanning report' | :dependency_scanning        | 2 | 7  | 4  | 7  | 4  | 6
      'with Container Scanning report'  | :container_scanning         | 1 | 8  | 8  | 8  | 8  | 8
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

      it 'inserts all vulnerabilties' do
        expect { subject }.to change { Vulnerability.count }.by(findings)
      end

      it 'calculates UUIDv5 for all findings' do
        subject
        uuids = Vulnerabilities::Finding.pluck(:uuid)
        expect(uuids).to all(be_uuid_v5)
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
    let(:scanner) { build(:vulnerabilities_scanner, project: project, external_id: 'bandit', name: 'Bandit') }
    let(:identifier) { build(:vulnerabilities_identifier, project: project, fingerprint: 'e6dd15eda2137be0034977a85b300a94a4f243a3') }
    let!(:new_artifact) { create(:ee_ci_job_artifact, :sast, job: new_build) }
    let(:new_build) { create(:ci_build, pipeline: new_pipeline) }
    let(:new_pipeline) { create(:ci_pipeline, project: project) }
    let(:new_report) { new_pipeline.security_reports.get_report(report_type.to_s, artifact) }
    let(:trait) { :sast }

    let!(:finding) do
      create(:vulnerabilities_finding,
        pipelines: [pipeline],
        identifiers: [identifier],
        primary_identifier: identifier,
        scanner: scanner,
        project: project,
        location_fingerprint: 'd869ba3f0b3347eb2749135a437dc07c8ae0f420')
    end

    let!(:vulnerability) { create(:vulnerability, findings: [finding], project: project) }

    before do
      project.add_developer(user)
      allow(new_pipeline).to receive(:user).and_return(user)
    end

    subject { described_class.new(new_pipeline, new_report).execute }

    it 'inserts only new scanners and reuse existing ones' do
      expect { subject }.to change { Vulnerabilities::Scanner.count }.by(2)
    end

    it 'inserts only new identifiers and reuse existing ones' do
      expect { subject }.to change { Vulnerabilities::Identifier.count }.by(16)
    end

    it 'inserts only new findings and reuse existing ones' do
      expect { subject }.to change { Vulnerabilities::Finding.count }.by(32)
    end

    it 'calculates UUIDv5 for all findings' do
      expect(Vulnerabilities::Finding.pluck(:uuid)).to all(be_a(String))
    end

    it 'inserts all finding pipelines (join model) for this new pipeline' do
      expect { subject }.to change { Vulnerabilities::FindingPipeline.where(pipeline: new_pipeline).count }.by(33)
    end

    it 'inserts new vulnerabilities with data from findings from this new pipeline' do
      expect { subject }.to change { Vulnerability.count }.by(32)
    end

    it 'updates existing findings with new data' do
      subject
      expect(finding.reload).to have_attributes(severity: 'medium', name: 'Probable insecure usage of temp file/directory.')
    end

    it 'updates existing vulnerability with new data' do
      subject
      expect(vulnerability.reload).to have_attributes(severity: 'medium', title: 'Probable insecure usage of temp file/directory.', title_html: 'Probable insecure usage of temp file/directory.')
    end

    context 'when the existing vulnerability is resolved with the latest report' do
      let!(:existing_vulnerability) { create(:vulnerability, report_type: report_type, project: project) }

      it 'marks the vulnerability as resolved on default branch' do
        expect { subject }.to change { existing_vulnerability.reload[:resolved_on_default_branch] }.from(false).to(true)
      end
    end

    context 'when the existing resolved vulnerability is discovered again on the latest report' do
      before do
        vulnerability.update!(resolved_on_default_branch: true)
      end

      it 'marks the vulnerability as not resolved on default branch' do
        expect { subject }.to change { vulnerability.reload[:resolved_on_default_branch] }.from(true).to(false)
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
end
