# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Geo::Replication::JobArtifactDownloader, :geo do
  include ::EE::GeoHelpers

  describe '#execute' do
    let_it_be(:secondary, reload: true) { create(:geo_node) }

    before do
      stub_current_geo_node(secondary)
    end

    context 'with job artifact' do
      context 'on local storage' do
        let(:job_artifact) { create(:ci_job_artifact) }

        subject(:downloader) { described_class.new(:job_artifact, job_artifact.id) }

        it 'downloads the job artifact from the primary' do
          result = Gitlab::Geo::Replication::BaseTransfer::Result.new(success: true, bytes_downloaded: 1)

          expect_next_instance_of(Gitlab::Geo::Replication::JobArtifactTransfer) do |instance|
            expect(instance).to receive(:download_from_primary).and_return(result)
          end

          expect(downloader.execute).to have_attributes(success: true, bytes_downloaded: 1)
        end
      end

      context 'on object storage' do
        before do
          stub_artifacts_object_storage
        end

        let!(:job_artifact) { create(:ci_job_artifact, :remote_store) }

        subject(:downloader) { described_class.new(:job_artifact, job_artifact.id) }

        it 'streams the job artifact file from the primary to object storage' do
          result = Gitlab::Geo::Replication::BaseTransfer::Result.new(success: true, bytes_downloaded: 1)

          expect_next_instance_of(Gitlab::Geo::Replication::JobArtifactTransfer) do |instance|
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
            stub_artifacts_object_storage(enabled: false)
          end

          it 'returns a result indicating a failure before a transfer was attempted' do
            result = downloader.execute

            expect(result).to have_attributes(
              success: false,
              failed_before_transfer: true,
              reason: 'Skipping transfer as this secondary node is not configured to store job artifact on Object Storage'
            )
          end
        end
      end
    end

    context 'with unknown object ID' do
      let(:unknown_id) { Ci::JobArtifact.maximum(:id).to_i + 1 }

      subject(:downloader) { described_class.new(:job_artifact, unknown_id) }

      it 'returns a result indicating a failure before a transfer was attempted' do
        result = downloader.execute

        expect(result).to have_attributes(
          success: false,
          failed_before_transfer: true,
          reason: "Skipping transfer as the job artifact (ID = #{unknown_id}) could not be found"
        )
      end
    end
  end
end
