# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Identifier do
  describe 'associations' do
    it { is_expected.to have_many(:finding_identifiers).class_name('Vulnerabilities::FindingIdentifier') }
    it { is_expected.to have_many(:findings).class_name('Vulnerabilities::Finding') }
    it { is_expected.to have_many(:primary_findings).class_name('Vulnerabilities::Finding') }
    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    let!(:identifier) { create(:vulnerabilities_identifier) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:external_type) }
    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_presence_of(:fingerprint) }
    # Uniqueness validation doesn't work with binary columns. See TODO in class file
    # it { is_expected.to validate_uniqueness_of(:fingerprint).scoped_to(:project_id) }
  end

  describe '.with_fingerprint' do
    let(:fingerprint) { 'f5724386167705667ae25a1390c0a516020690ba' }

    subject { described_class.with_fingerprint(fingerprint) }

    context 'when identifier has the corresponding fingerprint' do
      let!(:identifier) { create(:vulnerabilities_identifier, fingerprint: fingerprint) }

      it 'selects the identifier' do
        is_expected.to eq([identifier])
      end
    end

    context 'when identifier does not have the corresponding fingerprint' do
      let!(:identifier) { create(:vulnerabilities_identifier) }

      it 'does not select the identifier' do
        is_expected.to be_empty
      end
    end
  end
end
