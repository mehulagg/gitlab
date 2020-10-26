# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::Finding do
  describe 'associations' do
    it { is_expected.to belong_to(:scan).required }
    it { is_expected.to belong_to(:scanner).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:project_fingerprint) }
    it { is_expected.to validate_presence_of(:position) }
    it { is_expected.to validate_length_of(:project_fingerprint).is_at_most(40) }
  end

  describe '.by_position' do
    let!(:finding_1) { create(:security_finding, position: 0) }
    let!(:finding_2) { create(:security_finding, position: 1) }
    let(:expected_findings) { [finding_1] }

    subject { described_class.by_position(finding_1.position) }

    it { is_expected.to match_array(expected_findings) }
  end

  describe '.by_build_ids' do
    let!(:finding_1) { create(:security_finding) }
    let!(:finding_2) { create(:security_finding) }

    subject { described_class.by_build_ids(finding_1.scan.build_id) }

    it { is_expected.to eq([finding_1]) }
  end
end
