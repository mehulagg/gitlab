# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::Security::Finding do
  using RSpec::Parameterized::TableSyntax

  describe '#initialize' do
    subject { described_class.new(**params) }

    let_it_be(:primary_identifier) { build(:ci_reports_security_identifier) }
    let_it_be(:other_identifier) { build(:ci_reports_security_identifier) }
    let_it_be(:link) { build(:ci_reports_security_link) }
    let_it_be(:scanner) { build(:ci_reports_security_scanner) }
    let_it_be(:location) { build(:ci_reports_security_locations_sast) }
    let_it_be(:remediation) { build(:ci_reports_security_remediation) }

    let(:params) do
      {
        compare_key: 'this_is_supposed_to_be_a_unique_value',
        confidence: :medium,
        identifiers: [primary_identifier, other_identifier],
        links: [link],
        remediations: [remediation],
        location: location,
        metadata_version: 'sast:1.0',
        name: 'Cipher with no integrity',
        raw_metadata: 'I am a stringified json object',
        report_type: :sast,
        scanner: scanner,
        scan: nil,
        severity: :high,
        uuid: 'cadf8cf0a8228fa92a0f4897a0314083bb38',
        details: {
          'commit' => {
            'name' => [
              {
                'lang' => 'en',
                'value' => 'The Commit'
              }
            ],
            'description' => [
              {
                'lang' => 'en',
                'value' => 'Commit where the vulnerability was identified'
              }
            ],
            'type' => 'commit',
            'value' => '41df7b7eb3be2b5be2c406c2f6d28cd6631eeb19'
          }
        }
      }
    end

    context 'when both all params are given' do
      it 'initializes an instance' do
        expect { subject }.not_to raise_error

        expect(subject).to have_attributes(
          compare_key: 'this_is_supposed_to_be_a_unique_value',
          confidence: :medium,
          project_fingerprint: '9a73f32d58d87d94e3dc61c4c1a94803f6014258',
          identifiers: [primary_identifier, other_identifier],
          links: [link],
          remediations: [remediation],
          location: location,
          metadata_version: 'sast:1.0',
          name: 'Cipher with no integrity',
          raw_metadata: 'I am a stringified json object',
          report_type: :sast,
          scanner: scanner,
          severity: :high,
          uuid: 'cadf8cf0a8228fa92a0f4897a0314083bb38',
          details: {
            'commit' => {
              'name' => [
                {
                  'lang' => 'en',
                  'value' => 'The Commit'
                }
              ],
              'description' => [
                {
                  'lang' => 'en',
                  'value' => 'Commit where the vulnerability was identified'
                }
              ],
              'type' => 'commit',
              'value' => '41df7b7eb3be2b5be2c406c2f6d28cd6631eeb19'
            }
          }
        )
      end
    end

    %i[compare_key identifiers location metadata_version name raw_metadata report_type scanner uuid].each do |attribute|
      context "when attribute #{attribute} is missing" do
        before do
          params.delete(attribute)
        end

        it 'raises an error' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe "delegation" do
    subject { create(:ci_reports_security_finding) }

    %i[file_path start_line end_line].each do |attribute|
      it "delegates attribute #{attribute} to location" do
        expect(subject.public_send(attribute)).to eq(subject.location.public_send(attribute))
      end
    end
  end

  describe '#to_hash' do
    let(:occurrence) { create(:ci_reports_security_finding) }

    subject { occurrence.to_hash }

    it 'returns expected hash' do
      is_expected.to eq({
        compare_key: occurrence.compare_key,
        confidence: occurrence.confidence,
        identifiers: occurrence.identifiers,
        links: occurrence.links,
        location: occurrence.location,
        metadata_version: occurrence.metadata_version,
        name: occurrence.name,
        project_fingerprint: occurrence.project_fingerprint,
        raw_metadata: occurrence.raw_metadata,
        report_type: occurrence.report_type,
        scanner: occurrence.scanner,
        scan: occurrence.scan,
        severity: occurrence.severity,
        uuid: occurrence.uuid,
        details: occurrence.details
      })
    end
  end

  describe '#primary_identifier' do
    let(:primary_identifier) { create(:ci_reports_security_identifier) }
    let(:other_identifier) { create(:ci_reports_security_identifier) }

    let(:occurrence) { create(:ci_reports_security_finding, identifiers: [primary_identifier, other_identifier]) }

    subject { occurrence.primary_identifier }

    it 'returns the first identifier' do
      is_expected.to eq(primary_identifier)
    end
  end

  describe '#update_location' do
    let(:old_location) { create(:ci_reports_security_locations_sast, file_path: 'old_file.rb') }
    let(:new_location) { create(:ci_reports_security_locations_sast, file_path: 'new_file.rb') }

    let(:occurrence) { create(:ci_reports_security_finding, location: old_location) }

    subject { occurrence.update_location(new_location) }

    it 'assigns the new location and returns it' do
      subject

      expect(occurrence.location).to eq(new_location)
      is_expected.to eq(new_location)
    end

    it 'assigns the old location' do
      subject

      expect(occurrence.old_location).to eq(old_location)
    end
  end

  describe '#unsafe?' do
    where(:severity, :unsafe?) do
      'critical' | true
      'high'     | true
      'medium'   | false
      'low'      | false
      'info'     | false
      'unknown'  | true
    end

    with_them do
      let(:finding) { create(:ci_reports_security_finding, severity: severity) }

      subject { finding.unsafe? }

      it { is_expected.to be(unsafe?) }
    end
  end

  describe '#eql?' do
    let(:identifier) { build(:ci_reports_security_identifier) }
    let(:location) { build(:ci_reports_security_locations_sast) }
    let(:finding) { build(:ci_reports_security_finding, severity: 'low', report_type: :sast, identifiers: [identifier], location: location) }

    let(:report_type) { :secret_detection }
    let(:identifier_external_id) { 'foo' }
    let(:location_start_line) { 0 }
    let(:other_identifier) { build(:ci_reports_security_identifier, external_id: identifier_external_id) }
    let(:other_location) { build(:ci_reports_security_locations_sast, start_line: location_start_line) }
    let(:other_finding) do
      build(:ci_reports_security_finding,
            severity: 'low',
            report_type: report_type,
            identifiers: [other_identifier],
            location: other_location)
    end

    subject { finding.eql?(other_finding) }

    context 'when the primary_identifier is nil' do
      let(:identifier) { nil }

      it 'does not raise an exception' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when the other finding has same `report_type`' do
      let(:report_type) { :sast }

      context 'when the other finding has same primary identifier fingerprint' do
        let(:identifier_external_id) { identifier.external_id }

        context 'when the other finding has same location fingerprint' do
          let(:location_start_line) { location.start_line }

          it { is_expected.to be(true) }
        end

        context 'when the other finding does not have same location fingerprint' do
          it { is_expected.to be(false) }
        end
      end

      context 'when the other finding does not have same primary identifier fingerprint' do
        context 'when the other finding has same location fingerprint' do
          let(:location_start_line) { location.start_line }

          it { is_expected.to be(false) }
        end

        context 'when the other finding does not have same location fingerprint' do
          it { is_expected.to be(false) }
        end
      end
    end

    context 'when the other finding does not have same `report_type`' do
      context 'when the other finding has same primary identifier fingerprint' do
        let(:identifier_external_id) { identifier.external_id }

        context 'when the other finding has same location fingerprint' do
          let(:location_start_line) { location.start_line }

          it { is_expected.to be(false) }
        end

        context 'when the other finding does not have same location fingerprint' do
          it { is_expected.to be(false) }
        end
      end

      context 'when the other finding does not have same primary identifier fingerprint' do
        context 'when the other finding has same location fingerprint' do
          let(:location_start_line) { location.start_line }

          it { is_expected.to be(false) }
        end

        context 'when the other finding does not have same location fingerprint' do
          it { is_expected.to be(false) }
        end
      end
    end
  end

  describe '#valid?' do
    let(:scanner) { build(:ci_reports_security_scanner) }
    let(:identifiers) { [build(:ci_reports_security_identifier)] }
    let(:location) { build(:ci_reports_security_locations_sast) }
    let(:uuid) { SecureRandom.uuid }

    let(:finding) do
      build(:ci_reports_security_finding,
            scanner: scanner,
            identifiers: identifiers,
            location: location,
            uuid: uuid,
            compare_key: '')
    end

    subject { finding.valid? }

    context 'when the scanner is missing' do
      let(:scanner) { nil }

      it { is_expected.to be_falsey }
    end

    context 'when there is no identifier' do
      let(:identifiers) { [] }

      it { is_expected.to be_falsey }
    end

    context 'when the location is missing' do
      let(:location) { nil }

      it { is_expected.to be_falsey }
    end

    context 'when the uuid is missing' do
      let(:uuid) { nil }

      it { is_expected.to be_falsey }
    end

    context 'when all required attributes present' do
      it { is_expected.to be_truthy }
    end
  end

  describe '#keys' do
    let(:identifier_1) { build(:ci_reports_security_identifier) }
    let(:identifier_2) { build(:ci_reports_security_identifier) }
    let(:location) { build(:ci_reports_security_locations_sast) }
    let(:finding) { build(:ci_reports_security_finding, identifiers: [identifier_1, identifier_2], location: location) }
    let(:expected_keys) do
      [
        build(:ci_reports_security_finding_key, location_fingerprint: location.fingerprint, identifier_fingerprint: identifier_1.fingerprint),
        build(:ci_reports_security_finding_key, location_fingerprint: location.fingerprint, identifier_fingerprint: identifier_2.fingerprint)
      ]
    end

    subject { finding.keys }

    it { is_expected.to match_array(expected_keys) }
  end
end
