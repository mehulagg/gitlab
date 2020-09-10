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
    let(:scan) { create(:security_scan) }
    let!(:undismissed_finding) { create(:security_finding, scan: scan) }
    let!(:dismissed_finding) { create(:security_finding, scan: scan) }
    let(:expected_findings) { [undismissed_finding] }

    subject { described_class.undismissed }

    before do
      create(:vulnerability_feedback,
             :dismissal,
             project: scan.project,
             category: scan.scan_type,
             project_fingerprint: dismissed_finding.project_fingerprint)
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
end
