require 'spec_helper'

describe LfsObjectUploader do
  let(:lfs_object) { create(:lfs_object, :with_file) }
  let(:uploader) { described_class.new(lfs_object, :file) }
  let(:path) { Gitlab.config.lfs.storage_path }

  describe '#move_to_cache' do
    it 'is true' do
      expect(uploader.move_to_cache).to eq(true)
    end
  end

  describe '#move_to_store' do
    it 'is true' do
      expect(uploader.move_to_store).to eq(true)
    end
  end

  describe '#store_dir' do
    subject { uploader.store_dir }

    it { is_expected.to start_with(path) }
    it { is_expected.to end_with("#{lfs_object.oid[0, 2]}/#{lfs_object.oid[2, 2]}") }
  end

  describe '#cache_dir' do
    subject { uploader.cache_dir }

    it { is_expected.to start_with(path) }
    it { is_expected.to end_with('/tmp/cache') }
  end

  describe '#work_dir' do
    subject { uploader.work_dir }

    it { is_expected.to start_with(path) }
    it { is_expected.to end_with('/tmp/work') }
  end

  describe 'migration to object storage' do
    context 'with object storage disabled' do
      it "is skipped" do
        expect(ObjectStorageUploadWorker).not_to receive(:perform_async)

        lfs_object
      end
    end

    context 'with object storage enabled' do
      before do
        stub_lfs_object_storage(background_upload: true)
      end

      it 'is scheduled to run after creation' do
        expect(ObjectStorageUploadWorker).to receive(:perform_async).with(described_class.name, 'LfsObject', :file, kind_of(Numeric))

        lfs_object
      end
    end

    context 'with object storage unlicenced' do
      before do
        stub_lfs_object_storage(licensed: false)
      end

      it 'is skipped' do
        expect(ObjectStorageUploadWorker).not_to receive(:perform_async)

        lfs_object
      end
    end
  end

  describe 'remote file' do
    let(:remote) { described_class::REMOTE_STORE }
    let(:lfs_object) { create(:lfs_object, file_store: remote) }

    context 'with object storage enabled' do
      before do
        stub_lfs_object_storage
      end

      it 'can store file remotely' do
        allow(ObjectStorageUploadWorker).to receive(:perform_async)

        store_file(lfs_object)

        expect(lfs_object.file_store).to eq remote
        expect(lfs_object.file.path).not_to be_blank
      end
    end

    context 'with object storage unlicenced' do
      before do
        stub_lfs_object_storage(licensed: false)
      end

      it 'can not store file remotely' do
        expect { store_file(lfs_object) }.to raise_error('Object Storage feature is missing')
      end
    end
  end

  def store_file(lfs_object)
    lfs_object.file = fixture_file_upload(Rails.root + "spec/fixtures/dk.png", "`/png")
    lfs_object.save!
  end
end
