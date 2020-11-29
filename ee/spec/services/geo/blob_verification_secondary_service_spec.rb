# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::BlobVerificationSecondaryService, :geo do
  include ::EE::GeoHelpers

  let(:secondary) { create(:geo_node) }

  before do
    stub_current_geo_node(secondary)
  end

  describe '#execute' do
    let_it_be(:package_file) { create(:conan_package_file, :conan_recipe_file, verification_checksum: '62fc1ec4ce60') }

    let!(:registry) { create(:geo_package_file_registry, :synced, package_file: package_file) }

    subject(:service) { described_class.new(package_file.replicator) }

    it 'does not calculate the checksum when not running on a secondary' do
      stub_primary_node

      expect(package_file).not_to receive(:calculate_checksum)

      service.execute
    end

    it 'does not verify the checksum if resync is needed' do
      registry.resync

      expect(package_file).not_to receive(:calculate_checksum)

      service.execute
    end

    it 'does not verify the checksum if sync is started' do
      registry.start!

      expect(package_file).not_to receive(:calculate_checksum)

      service.execute
    end

    it 'does not verify the checksum if primary was never verified' do
      package_file.assign_attributes(verification_checksum: nil)

      expect(package_file).not_to receive(:calculate_checksum)

      service.execute
    end

    it 'does not verify the checksum if the current checksum matches' do
      package_file.assign_attributes(verification_checksum: '62fc1ec4ce60')
      registry.update(verification_checksum: '62fc1ec4ce60')

      expect(package_file).not_to receive(:calculate_checksum)

      service.execute
    end

    it 'sets checksum when the checksum matches' do
      allow(package_file).to receive(:calculate_checksum).and_return('62fc1ec4ce60')

      service.execute

      expect(registry.reload).to have_attributes(
        verification_checksum: '62fc1ec4ce60',
        checksum_mismatch: false,
        verified_at: be_within(1.minute).of(Time.current),
        verification_failure: nil,
        verification_retry_count: nil,
        retry_at: nil,
        retry_count: nil
      )
    end

    context 'when the checksum mismatch' do
      before do
        allow(package_file).to receive(:calculate_checksum).and_return('99fc1ec4ce60')
      end

      it 'keeps track of failures' do
        service.execute

        expect(registry.reload).to have_attributes(
          verification_checksum: nil,
          verification_checksum_mismatched: '99fc1ec4ce60',
          checksum_mismatch: true,
          verified_at: be_within(1.minute).of(Time.current),
          verification_failure: 'checksum mismatch',
          verification_retry_count: 1,
          retry_at: be_present,
          retry_count: 1
        )
      end

      it 'ensures the next retry time is capped properly' do
        registry.update(retry_count: 30)

        service.execute

        expect(registry.reload).to have_attributes(
          retry_at: be_within(100.seconds).of(1.hour.from_now),
          retry_count: 31
        )
      end
    end

    context 'when checksum calculation fails' do
      before do
        allow(package_file).to receive(:calculate_checksum).and_raise('Error calculating checksum')
      end

      it 'keeps track of failures' do
        service.execute

        expect(registry.reload).to have_attributes(
          verification_checksum: nil,
          verification_checksum_mismatched: nil,
          checksum_mismatch: false,
          verified_at: be_within(1.minute).of(Time.current),
          verification_failure: 'Error calculating checksum',
          verification_retry_count: 1,
          retry_at: be_present,
          retry_count: 1
        )
      end

      it 'ensures the next retry time is capped properly' do
        registry.update(retry_count: 30)

        service.execute

        expect(registry.reload).to have_attributes(
          retry_at: be_within(100.seconds).of(1.hour.from_now),
          retry_count: 31
        )
      end
    end
  end
end
