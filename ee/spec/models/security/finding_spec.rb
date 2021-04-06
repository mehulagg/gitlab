# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::Finding do
  describe 'associations' do
    it { is_expected.to belong_to(:scan).required }
    it { is_expected.to belong_to(:scanner).required }
    it { is_expected.to have_one(:build).through(:scan) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:project_fingerprint) }
    it { is_expected.to validate_length_of(:project_fingerprint).is_at_most(40) }
    it { is_expected.to validate_presence_of(:uuid) }
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:scan_type).to(:scan).allow_nil }
  end

  describe '.by_uuid' do
    let!(:finding_1) { create(:security_finding) }
    let!(:finding_2) { create(:security_finding) }
    let(:expected_findings) { [finding_1] }

    subject { described_class.by_uuid(finding_1.uuid) }

    it { is_expected.to match_array(expected_findings) }
  end

  describe '.by_build_ids' do
    let!(:finding_1) { create(:security_finding) }
    let!(:finding_2) { create(:security_finding) }

    subject { described_class.by_build_ids(finding_1.scan.build_id) }

    it { is_expected.to eq([finding_1]) }
  end

  describe '.by_severity_levels' do
    let!(:critical_severity_finding) { create(:security_finding, severity: :critical) }
    let!(:high_severity_finding) { create(:security_finding, severity: :high) }
    let(:expected_findings) { [critical_severity_finding] }

    subject { described_class.by_severity_levels(:critical) }

    it { is_expected.to match_array(expected_findings) }
  end

  describe '.by_confidence_levels' do
    let!(:high_confidence_finding) { create(:security_finding, confidence: :high) }
    let!(:low_confidence_finding) { create(:security_finding, confidence: :low) }
    let(:expected_findings) { [high_confidence_finding] }

    subject { described_class.by_confidence_levels(:high) }

    it { is_expected.to match_array(expected_findings) }
  end

  describe '.by_report_types' do
    let!(:sast_scan) { create(:security_scan, scan_type: :sast) }
    let!(:dast_scan) { create(:security_scan, scan_type: :dast) }
    let!(:sast_finding) { create(:security_finding, scan: sast_scan) }
    let!(:dast_finding) { create(:security_finding, scan: dast_scan) }
    let(:expected_findings) { [sast_finding] }

    subject { described_class.by_report_types(:sast) }

    it { is_expected.to match_array(expected_findings) }
  end

  describe '.by_project_fingerprints' do
    let!(:finding_1) { create(:security_finding) }
    let!(:finding_2) { create(:security_finding) }
    let(:expected_findings) { [finding_1] }

    subject { described_class.by_project_fingerprints(finding_1.project_fingerprint) }

    it { is_expected.to match_array(expected_findings) }
  end

  describe '.undismissed' do
    let(:scan_1) { create(:security_scan) }
    let(:scan_2) { create(:security_scan) }
    let!(:undismissed_finding) { create(:security_finding, scan: scan_1) }
    let!(:dismissed_finding) { create(:security_finding, scan: scan_1) }
    let(:expected_findings) { [undismissed_finding] }

    subject { described_class.undismissed }

    before do
      create(:vulnerability_feedback,
             :dismissal,
             project: scan_1.project,
             category: scan_1.scan_type,
             project_fingerprint: dismissed_finding.project_fingerprint)

      create(:vulnerability_feedback,
             :dismissal,
             project: scan_2.project,
             category: scan_2.scan_type,
             project_fingerprint: undismissed_finding.project_fingerprint)
    end

    it { is_expected.to match_array(expected_findings) }
  end

  describe '.ordered' do
    let!(:finding_1) { create(:security_finding, severity: :high, confidence: :unknown) }
    let!(:finding_2) { create(:security_finding, severity: :low, confidence: :confirmed) }
    let!(:finding_3) { create(:security_finding, severity: :critical, confidence: :confirmed) }
    let!(:finding_4) { create(:security_finding, severity: :critical, confidence: :high) }

    let(:expected_findings) { [finding_3, finding_4, finding_1, finding_2] }

    subject { described_class.ordered }

    it { is_expected.to eq(expected_findings) }
  end

  describe '.deduplicated' do
    let!(:finding_1) { create(:security_finding, deduplicated: true) }
    let!(:finding_2) { create(:security_finding, deduplicated: false) }

    let(:expected_findings) { [finding_1] }

    subject { described_class.deduplicated }

    it { is_expected.to eq(expected_findings) }
  end

  describe '.count_by_scan_type' do
    let!(:sast_scan) { create(:security_scan, scan_type: :sast) }
    let!(:dast_scan) { create(:security_scan, scan_type: :dast) }
    let!(:finding_1) { create(:security_finding, scan: sast_scan) }
    let!(:finding_2) { create(:security_finding, scan: sast_scan) }
    let!(:finding_3) { create(:security_finding, scan: dast_scan) }

    subject { described_class.count_by_scan_type }

    it {
      is_expected.to eq({
        Security::Scan.scan_types['dast'] => 1,
        Security::Scan.scan_types['sast'] => 2
      })
    }
  end
end
