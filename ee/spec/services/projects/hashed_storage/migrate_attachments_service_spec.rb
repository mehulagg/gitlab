# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::HashedStorage::MigrateAttachmentsService do
  include EE::GeoHelpers

  let(:project) { create(:project, storage_version: 1) }
  let(:legacy_storage) { Storage::LegacyProject.new(project) }
  let(:hashed_storage) { Storage::Hashed.new(project) }
  let(:old_attachments_path) { legacy_storage.disk_path }
  let(:new_attachments_path) { hashed_storage.disk_path }

  let_it_be(:primary) { create(:geo_node, :primary) }
  let_it_be(:secondary) { create(:geo_node) }

  subject { described_class.new(project: project, old_disk_path: old_attachments_path) }

  before do
    stub_current_geo_node(primary)
  end

  describe '#execute' do
    context 'on success' do
      before do
        TestEnv.clean_test_path
        FileUtils.mkdir_p(File.join(FileUploader.root, old_attachments_path))
      end

      it 'returns true' do
        expect(subject.execute).to be_truthy
      end

      it 'creates a Geo::HashedStorageAttachmentsEvent' do
        expect { subject.execute }.to change(Geo::EventLog, :count).by(1)

        event = Geo::EventLog.first.event

        expect(event).to be_a(Geo::HashedStorageAttachmentsEvent)
        expect(event).to have_attributes(
          old_attachments_path: old_attachments_path,
          new_attachments_path: new_attachments_path
        )
      end
    end

    context 'on failure' do
      it 'does not create a Geo event when skipped' do
        expect { subject.execute }.not_to change { Geo::EventLog.count }
      end

      it 'does not create a Geo event on failure' do
        expect(subject).to receive(:move_folder!).and_raise(::Projects::HashedStorage::AttachmentMigrationError)
        expect { subject.execute }.to raise_error(::Projects::HashedStorage::AttachmentMigrationError)
        expect(Geo::EventLog.count).to eq(0)
      end
    end
  end
end
