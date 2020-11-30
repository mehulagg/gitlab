# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Scanner do
  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:findings).class_name('Vulnerabilities::Finding') }
    it { is_expected.to have_many(:security_findings).class_name('Security::Finding') }
  end

  describe 'validations' do
    let!(:scanner) { create(:vulnerabilities_scanner) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_uniqueness_of(:external_id).scoped_to(:project_id) }
    it { is_expected.to validate_length_of(:vendor).is_at_most(255) }
  end

  describe '.with_external_id' do
    let(:external_id) { 'bandit' }

    subject { described_class.with_external_id(external_id) }

    context 'when scanner has the corresponding external_id' do
      let!(:scanner) { create(:vulnerabilities_scanner, external_id: external_id) }

      it 'selects the scanner' do
        is_expected.to eq([scanner])
      end
    end

    context 'when scanner does not have the corresponding external_id' do
      let!(:scanner) { create(:vulnerabilities_scanner) }

      it 'does not select the scanner' do
        is_expected.to be_empty
      end
    end
  end
end
