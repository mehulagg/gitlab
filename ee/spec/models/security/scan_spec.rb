# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::Scan do
  describe 'associations' do
    it { is_expected.to belong_to(:build) }
    it { is_expected.to have_one(:pipeline).through(:build).class_name('Ci::Pipeline') }
    it { is_expected.to have_many(:findings) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:build_id) }
    it { is_expected.to validate_presence_of(:scan_type) }
  end

  describe '#project' do
    it { is_expected.to delegate_method(:project).to(:build) }
  end

  describe '.by_scan_types' do
    let!(:sast_scan) { create(:security_scan, scan_type: :sast) }
    let!(:dast_scan) { create(:security_scan, scan_type: :dast) }
    let(:expected_scans) { [sast_scan] }

    subject { described_class.by_scan_types(:sast) }

    it { is_expected.to match_array(expected_scans) }
  end

  describe '.latest_successful_by_build' do
    let!(:first_successful_scan) { create(:security_scan, build: create(:ci_build, :success, :retried)) }
    let!(:second_successful_scan) { create(:security_scan, build: create(:ci_build, :success)) }
    let!(:failed_scan) { create(:security_scan, build: create(:ci_build, :failed)) }

    subject { described_class.latest_successful_by_build }

    it { is_expected.to match_array([second_successful_scan]) }
  end

  describe '.has_dismissal_feedback' do
    let(:scan_1) { create(:security_scan) }
    let(:scan_2) { create(:security_scan) }
    let(:expected_scans) { [scan_1] }

    subject { described_class.has_dismissal_feedback }

    before do
      create(:vulnerability_feedback, :dismissal, project: scan_1.project, category: scan_1.scan_type)
      create(:vulnerability_feedback, :issue, project: scan_2.project, category: scan_2.scan_type)
    end

    it { is_expected.to match_array(expected_scans) }
  end

  it_behaves_like 'having unique enum values'
end
