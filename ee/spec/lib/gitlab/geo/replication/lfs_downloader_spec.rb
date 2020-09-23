# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Geo::Replication::LfsDownloader, :geo do
  include ::EE::GeoHelpers

  describe '#execute' do
    let_it_be(:secondary, reload: true) { create(:geo_node) }

    before do
      stub_current_geo_node(secondary)
    end

    context 'with LFS object' do
      context 'on local storage' do
        let(:lfs_object) { create(:lfs_object) }

        subject(:downloader) { described_class.new(:lfs, lfs_object.id) }

        it 'downloads the LFS file from the primary' do
          result = Gitlab::Geo::Replication::BaseTransfer::Result.new(success: true, bytes_downloaded: 1)

          expect_next_instance_of(Gitlab::Geo::Replication::LfsTransfer) do |instance|
            expect(instance).to receive(:download_from_primary).and_return(result)
          end

          expect(downloader.execute).to have_attributes(success: true, bytes_downloaded: 1)
        end
      end

      context 'on object storage' do
        before do
          stub_lfs_object_storage
        end

        let!(:lfs_object) { create(:lfs_object, :object_storage) }

        subject(:downloader) { described_class.new(:lfs, lfs_object.id) }

        it 'streams the LFS file from the primary to object storage' do
          result = Gitlab::Geo::Replication::BaseTransfer::Result.new(success: true, bytes_downloaded: 1)

          expect_next_instance_of(Gitlab::Geo::Replication::LfsTransfer) do |instance|
            expect(instance).to receive(:stream_from_primary_to_object_storage).and_return(result)
          end

          expect(downloader.execute).to have_attributes(success: true, bytes_downloaded: 1)
        end

        context 'with object storage sync disabled' do
          before do
            secondary.update_column(:sync_object_storage, false)
          end

          it 'returns a result indicating a failure before a transfer was attempted' do
            result = downloader.execute

            expect(result).to have_attributes(
              success: false,
              failed_before_transfer: true,
              reason: 'Skipping transfer as this secondary node is not allowed to replicate content on Object Storage'
            )
          end
        end

        context 'with object storage disabled' do
          before do
            stub_lfs_object_storage(enabled: false)
          end

          it 'returns a result indicating a failure before a transfer was attempted' do
            result = downloader.execute

            expect(result).to have_attributes(
              success: false,
              failed_before_transfer: true,
              reason: 'Skipping transfer as this secondary node is not configured to store lfs on Object Storage'
            )
          end
        end
      end
    end

    context 'with unknown object ID' do
      let(:unknown_id) { LfsObject.maximum(:id).to_i + 1 }

      subject(:downloader) { described_class.new(:lfs, unknown_id) }

      it 'returns a result indicating a failure before a transfer was attempted' do
        result = downloader.execute

        expect(result).to have_attributes(
          success: false,
          failed_before_transfer: true,
          reason: "Skipping transfer as the lfs (ID = #{unknown_id}) could not be found"
        )
      end
    end
  end
end
