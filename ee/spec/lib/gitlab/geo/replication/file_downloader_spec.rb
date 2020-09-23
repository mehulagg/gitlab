# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Geo::Replication::FileDownloader, :geo do
  include EE::GeoHelpers

  describe '#execute' do
    let_it_be(:primary_node) { create(:geo_node, :primary) }
    let_it_be(:secondary, reload: true) { create(:geo_node) }

    before do
      stub_current_geo_node(secondary)
    end

    context 'with upload' do
      context 'on local storage' do
        let(:upload) { create(:upload, :with_file) }

        subject(:downloader) { described_class.new(:avatar, upload.id) }

        it 'downloads the file from the primary' do
          stub_geo_file_transfer(:avatar, upload)

          expect_next_instance_of(Gitlab::Geo::Replication::FileTransfer) do |instance|
            expect(instance).to receive(:download_from_primary).and_call_original
          end

          expect(downloader.execute).to have_attributes(success: true)
        end
      end

      context 'on object storage' do
        before do
          stub_uploads_object_storage(AvatarUploader, direct_upload: true)
        end

        let!(:upload) { create(:upload, :object_storage) }

        subject(:downloader) { described_class.new(:avatar, upload.id) }

        it 'streams the upload file from the primary to object storage' do
          stub_geo_file_transfer_object_storage(:avatar, upload)

          expect_next_instance_of(Gitlab::Geo::Replication::FileTransfer) do |instance|
            expect(instance).to receive(:stream_from_primary_to_object_storage).and_call_original
          end

          expect(downloader.execute).to have_attributes(success: true)
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
            stub_uploads_object_storage(AvatarUploader, enabled: false)
          end

          it 'returns a result indicating a failure before a transfer was attempted' do
            result = downloader.execute

            expect(result).to have_attributes(
              success: false,
              failed_before_transfer: true,
              reason: 'Skipping transfer as this secondary node is not configured to store avatar on Object Storage'
            )
          end
        end
      end
    end

    context 'with unknown object ID' do
      let(:unknown_id) { Upload.maximum(:id).to_i + 1 }

      subject(:downloader) { described_class.new(:avatar, unknown_id) }

      it 'returns a result indicating a failure before a transfer was attempted' do
        result = downloader.execute

        expect(result).to have_attributes(
          success: false,
          failed_before_transfer: true,
          reason: "Skipping transfer as the avatar (ID = #{unknown_id}) could not be found"
        )
      end
    end

    context 'when the upload parent object does not exist' do
      let(:upload) { create(:upload) }

      subject(:downloader) { described_class.new(:avatar, upload.id) }

      before do
        upload.update_columns(model_id: nil, model_type: nil)
      end

      it 'returns a result indicating a failure before a transfer was attempted' do
        result = downloader.execute

        expect(result).to have_attributes(
          success: true,
          primary_missing_file: true # FIXME: https://gitlab.com/gitlab-org/gitlab/-/issues/220855
        )
      end
    end
  end

  def stub_geo_file_transfer(file_type, upload)
    url = primary_node.geo_transfers_url(file_type, upload.id.to_s)

    stub_request(:get, url).to_return(status: 200, body: upload.retrieve_uploader.file.read, headers: {})
  end

  def stub_geo_file_transfer_object_storage(file_type, upload)
    url = primary_node.geo_transfers_url(file_type, upload.id.to_s)
    redirection = upload.retrieve_uploader.url
    file = fixture_file_upload('spec/fixtures/dk.png')

    stub_request(:get, url).to_return(status: 307, headers: { location: redirection })
    stub_request(:get, redirection).to_return(status: 200, body: file.read, headers: {})
  end
end
