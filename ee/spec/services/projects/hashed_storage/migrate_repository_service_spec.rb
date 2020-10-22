# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::HashedStorage::MigrateRepositoryService do
  include EE::GeoHelpers

  let(:gitlab_shell) { Gitlab::Shell.new }
  let(:project) { create(:project, :empty_repo, :wiki_repo, :design_repo, :legacy_storage) }
  let(:legacy_storage) { Storage::LegacyProject.new(project) }
  let(:hashed_storage) { Storage::Hashed.new(project) }
  let(:old_disk_path) { legacy_storage.disk_path }
  let(:new_disk_path) { hashed_storage.disk_path }

  subject(:service) { described_class.new(project: project, old_disk_path: old_disk_path) }

  describe '#execute' do
    context 'when running on a Geo primary node' do
      let_it_be(:primary) { create(:geo_node, :primary) }
      let_it_be(:secondary) { create(:geo_node) }

      before do
        stub_current_geo_node(primary)
      end

      it 'creates a Geo::HashedStorageMigratedEvent on success' do
        expect { service.execute }.to change(Geo::EventLog, :count).by(1)

        event = Geo::EventLog.first.event

        expect(event).to be_a(Geo::HashedStorageMigratedEvent)
        expect(event).to have_attributes(
          old_storage_version: nil,
          new_storage_version: ::Project::HASHED_STORAGE_FEATURES[:repository],
          old_disk_path: legacy_storage.disk_path,
          new_disk_path: hashed_storage.disk_path,
          old_wiki_disk_path: legacy_storage.disk_path + '.wiki',
          new_wiki_disk_path: hashed_storage.disk_path + '.wiki',
          old_design_disk_path: legacy_storage.disk_path + '.design',
          new_design_disk_path: hashed_storage.disk_path + '.design'
        )
      end

      it 'does not create a Geo event on failure' do
        from_name = project.disk_path
        to_name = hashed_storage.disk_path

        allow(service).to receive(:move_repository).and_call_original
        allow(service).to receive(:move_repository).with(from_name, to_name).once { false } # will disable first move only

        expect { service.execute }.not_to change { Geo::EventLog.count }
      end
    end
  end
end
