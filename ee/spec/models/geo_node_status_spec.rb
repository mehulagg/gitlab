# frozen_string_literal: true

require 'spec_helper'

describe GeoNodeStatus, :geo, :geo_fdw do
  include ::EE::GeoHelpers

  let!(:primary) { create(:geo_node, :primary) }
  let!(:secondary) { create(:geo_node) }

  let!(:group)     { create(:group) }
  let!(:project_1) { create(:project, group: group) }
  let!(:project_2) { create(:project, group: group) }
  let!(:project_3) { create(:project) }
  let!(:project_4) { create(:project) }

  subject(:status) { described_class.current_node_status }

  before do
    stub_current_geo_node(secondary)
  end

  describe '#fast_current_node_status' do
    it 'reads the cache and spawns the worker' do
      expect(described_class).to receive(:spawn_worker).once

      rails_cache = double
      expect(rails_cache).to receive(:read).with(described_class.cache_key)
      expect(Rails).to receive(:cache).and_return(rails_cache)

      described_class.fast_current_node_status
    end
  end

  describe '#update_cache!' do
    it 'writes a cache' do
      rails_cache = double
      allow(Rails).to receive(:cache).and_return(rails_cache)
      allow(rails_cache).to receive(:fetch).with('flipper:persisted_names', expires_in: 1.minute).and_return([described_class.cache_key])

      expect(rails_cache).to receive(:write).with(described_class.cache_key, kind_of(Hash))

      described_class.new.update_cache!
    end
  end

  describe '#healthy?' do
    context 'when health is blank' do
      it 'returns true' do
        subject.status_message = ''

        expect(subject.healthy?).to be true
      end
    end

    context 'when health is present' do
      it 'returns true' do
        subject.status_message = GeoNodeStatus::HEALTHY_STATUS

        expect(subject.healthy?).to be true
      end

      it 'returns false' do
        subject.status_message = 'something went wrong'

        expect(subject.healthy?).to be false
      end
    end

    context 'takes outdated? into consideration' do
      it 'return false' do
        subject.status_message = GeoNodeStatus::HEALTHY_STATUS
        subject.updated_at = 10.minutes.ago

        expect(subject.healthy?).to be false
      end

      it 'return false' do
        subject.status_message = 'something went wrong'
        subject.updated_at = 1.minute.ago

        expect(subject.healthy?).to be false
      end
    end
  end

  describe '#outdated?' do
    it 'return true' do
      subject.updated_at = 10.minutes.ago

      expect(subject.outdated?).to be true
    end

    it 'return false' do
      subject.updated_at = 1.minute.ago

      expect(subject.outdated?).to be false
    end
  end

  describe '#status_message' do
    it 'delegates to the HealthCheck' do
      expect(HealthCheck::Utils).to receive(:process_checks).with(['geo']).once

      subject
    end
  end

  describe '#health' do
    context 'takes outdated? into consideration' do
      it 'returns expiration error' do
        subject.status_message = GeoNodeStatus::HEALTHY_STATUS
        subject.updated_at = 10.minutes.ago

        expect(subject.health).to eq "Status has not been updated in the past #{described_class::EXPIRATION_IN_MINUTES} minutes"
      end

      it 'returns original message' do
        subject.status_message = 'something went wrong'
        subject.updated_at = 1.minute.ago

        expect(subject.health).to eq 'something went wrong'
      end
    end
  end

  describe '#projects_count' do
    it 'counts the number of projects' do
      expect(subject.projects_count).to eq 4
    end
  end

  describe '#attachments_synced_count' do
    it 'only counts successful syncs' do
      create_list(:user, 3, avatar: fixture_file_upload('spec/fixtures/dk.png', 'image/png'))
      uploads = Upload.all.pluck(:id)

      create(:geo_upload_registry, :avatar, file_id: uploads[0])
      create(:geo_upload_registry, :avatar, file_id: uploads[1])
      create(:geo_upload_registry, :avatar, :failed, file_id: uploads[2])

      expect(subject.attachments_synced_count).to eq(2)
    end

    it 'does not count synced files that were replaced' do
      user = create(:user, avatar: fixture_file_upload('spec/fixtures/dk.png', 'image/png'))

      expect(subject.attachments_count).to eq(1)
      expect(subject.attachments_synced_count).to eq(0)

      upload = Upload.find_by(model: user, uploader: 'AvatarUploader')
      create(:geo_upload_registry, :avatar, file_id: upload.id)

      subject = described_class.current_node_status

      expect(subject.attachments_count).to eq(1)
      expect(subject.attachments_synced_count).to eq(1)

      user.update(avatar: fixture_file_upload('spec/fixtures/rails_sample.jpg', 'image/jpeg'))

      subject = described_class.current_node_status

      expect(subject.attachments_count).to eq(1)
      expect(subject.attachments_synced_count).to eq(0)

      upload = Upload.find_by(model: user, uploader: 'AvatarUploader')
      create(:geo_upload_registry, :avatar, file_id: upload.id)

      subject = described_class.current_node_status

      expect(subject.attachments_count).to eq(1)
      expect(subject.attachments_synced_count).to eq(1)
    end
  end

  describe '#attachments_synced_missing_on_primary_count' do
    it 'only counts successful syncs' do
      create_list(:user, 3, avatar: fixture_file_upload('spec/fixtures/dk.png', 'image/png'))
      uploads = Upload.all.pluck(:id)

      create(:geo_upload_registry, :avatar, file_id: uploads[0], missing_on_primary: true)
      create(:geo_upload_registry, :avatar, file_id: uploads[1])
      create(:geo_upload_registry, :avatar, :failed, file_id: uploads[2])

      expect(subject.attachments_synced_missing_on_primary_count).to eq(1)
    end
  end

  describe '#attachments_failed_count' do
    it 'counts failed avatars, attachment, personal snippets and files' do
      # These two should be ignored
      create(:geo_lfs_object_registry, :with_lfs_object, :failed)
      create(:geo_upload_registry, :with_file)

      create(:geo_upload_registry, :with_file, :failed, file_type: :personal_file)
      create(:geo_upload_registry, :with_file, :failed, file_type: :attachment)
      create(:geo_upload_registry, :avatar, :with_file, :failed)
      create(:geo_upload_registry, :with_file, :failed)

      expect(subject.attachments_failed_count).to eq(4)
    end
  end

  describe '#attachments_synced_in_percentage' do
    let(:avatar) { fixture_file_upload('spec/fixtures/dk.png') }
    let(:upload_1) { create(:upload, model: group, path: avatar) }
    let(:upload_2) { create(:upload, model: project_1, path: avatar) }

    before do
      create(:upload, model: create(:group), path: avatar)
      create(:upload, model: project_3, path: avatar)
    end

    it 'returns 0 when no objects are available' do
      expect(subject.attachments_synced_in_percentage).to eq(0)
    end

    it 'returns the right percentage with no group restrictions' do
      create(:geo_upload_registry, :avatar, file_id: upload_1.id)
      create(:geo_upload_registry, :avatar, file_id: upload_2.id)

      expect(subject.attachments_synced_in_percentage).to be_within(0.0001).of(50)
    end

    it 'returns the right percentage with group restrictions' do
      secondary.update!(selective_sync_type: 'namespaces', namespaces: [group])
      create(:geo_upload_registry, :avatar, file_id: upload_1.id)
      create(:geo_upload_registry, :avatar, file_id: upload_2.id)

      expect(subject.attachments_synced_in_percentage).to be_within(0.0001).of(100)
    end
  end

  describe '#db_replication_lag_seconds' do
    it 'returns the set replication lag if secondary' do
      allow(Gitlab::Geo).to receive(:secondary?).and_return(true)
      geo_health_check = double('Gitlab::Geo::HealthCheck', perform_checks: '', db_replication_lag_seconds: 1000)
      allow(Gitlab::Geo::HealthCheck).to receive(:new).and_return(geo_health_check)

      expect(subject.db_replication_lag_seconds).to eq(1000)
    end

    it "doesn't attempt to set replication lag if primary" do
      stub_current_geo_node(primary)

      expect(subject.db_replication_lag_seconds).to eq(nil)
    end
  end

  describe '#lfs_objects_synced_count' do
    it 'counts synced LFS objects' do
      # These four should be ignored
      create(:geo_upload_registry, :failed)
      create(:geo_upload_registry, :avatar)
      create(:geo_upload_registry, file_type: :attachment)
      create(:geo_lfs_object_registry, :with_lfs_object, :failed)

      create(:geo_lfs_object_registry, :with_lfs_object)

      expect(subject.lfs_objects_synced_count).to eq(1)
    end
  end

  describe '#lfs_objects_synced_missing_on_primary_count' do
    it 'counts LFS objects marked as synced due to file missing on the primary' do
      # These four should be ignored
      create(:geo_upload_registry, :failed)
      create(:geo_upload_registry, :avatar, missing_on_primary: true)
      create(:geo_upload_registry, file_type: :attachment, missing_on_primary: true)
      create(:geo_lfs_object_registry, :with_lfs_object, :failed)

      create(:geo_lfs_object_registry, :with_lfs_object, missing_on_primary: true)

      expect(subject.lfs_objects_synced_missing_on_primary_count).to eq(1)
    end
  end

  describe '#lfs_objects_failed_count' do
    it 'counts failed LFS objects' do
      # These four should be ignored
      create(:geo_upload_registry, :failed)
      create(:geo_upload_registry, :avatar, :failed)
      create(:geo_upload_registry, :failed, file_type: :attachment)
      create(:geo_lfs_object_registry, :with_lfs_object)

      create(:geo_lfs_object_registry, :with_lfs_object, :failed)

      expect(subject.lfs_objects_failed_count).to eq(1)
    end
  end

  describe '#lfs_objects_synced_in_percentage' do
    let(:lfs_object_project) { create(:lfs_objects_project, project: project_1) }

    before do
      allow(ProjectCacheWorker).to receive(:perform_async).and_return(true)

      create(:lfs_objects_project, project: project_1)
      create_list(:lfs_objects_project, 2, project: project_3)
    end

    it 'returns 0 when no objects are available' do
      expect(subject.lfs_objects_synced_in_percentage).to eq(0)
    end

    it 'returns the right percentage with no group restrictions' do
      create(:geo_lfs_object_registry, lfs_object_id: lfs_object_project.lfs_object_id)

      expect(subject.lfs_objects_synced_in_percentage).to be_within(0.0001).of(25)
    end

    it 'returns the right percentage with group restrictions' do
      secondary.update!(selective_sync_type: 'namespaces', namespaces: [group])
      create(:geo_lfs_object_registry, lfs_object_id: lfs_object_project.lfs_object_id)

      expect(subject.lfs_objects_synced_in_percentage).to be_within(0.0001).of(50)
    end
  end

  describe '#job_artifacts_synced_count' do
    it 'counts synced job artifacts' do
      # These should be ignored
      create(:geo_upload_registry)
      create(:geo_job_artifact_registry, :with_artifact, success: false)

      create(:geo_job_artifact_registry, :with_artifact, success: true)

      expect(subject.job_artifacts_synced_count).to eq(1)
    end
  end

  describe '#job_artifacts_synced_missing_on_primary_count' do
    it 'counts job artifacts marked as synced due to file missing on the primary' do
      # These should be ignored
      create(:geo_upload_registry, missing_on_primary: true)
      create(:geo_job_artifact_registry, :with_artifact, success: true)

      create(:geo_job_artifact_registry, :with_artifact, success: true, missing_on_primary: true)

      expect(subject.job_artifacts_synced_missing_on_primary_count).to eq(1)
    end
  end

  describe '#job_artifacts_failed_count' do
    context 'when geo_job_artifact_registry_ssot_sync is disabled' do
      before do
        stub_feature_flags(geo_job_artifact_registry_ssot_sync: false)
      end

      it 'counts failed job artifacts' do
        # These should be ignored
        create(:geo_upload_registry, :failed)
        create(:geo_upload_registry, :avatar, :failed)
        create(:geo_upload_registry, :attachment, :failed)
        create(:geo_job_artifact_registry, :with_artifact, success: true)

        create(:geo_job_artifact_registry, :with_artifact, success: false)

        expect(subject.job_artifacts_failed_count).to eq(1)
      end
    end

    context 'when geo_job_artifact_registry_ssot_sync is enabled' do
      before do
        stub_feature_flags(geo_job_artifact_registry_ssot_sync: true)
      end

      it 'counts failed job artifacts' do
        # These should be ignored
        create(:geo_upload_registry, :failed)
        create(:geo_upload_registry, :avatar, :failed)
        create(:geo_upload_registry, :attachment, :failed)
        create(:geo_job_artifact_registry, :with_artifact, success: true)

        create(:geo_job_artifact_registry, :with_artifact, :failed)

        expect(subject.job_artifacts_failed_count).to eq(1)
      end
    end
  end

  describe '#job_artifacts_synced_in_percentage' do
    context 'when artifacts are available' do
      before do
        [project_1, project_2, project_3, project_4].each_with_index do |project, index|
          build = create(:ci_build, project: project)
          job_artifact = create(:ci_job_artifact, job: build)

          create(:geo_job_artifact_registry, success: index.even?, artifact_id: job_artifact.id)
        end
      end

      it 'returns the right percentage with no group restrictions' do
        expect(subject.job_artifacts_synced_in_percentage).to be_within(0.0001).of(50)
      end

      it 'returns the right percentage with group restrictions' do
        secondary.update_attribute(:namespaces, [group])

        expect(subject.job_artifacts_synced_in_percentage).to be_within(0.0001).of(50)
      end
    end

    it 'returns 0 when no artifacts are available' do
      expect(subject.job_artifacts_synced_in_percentage).to eq(0)
    end
  end

  describe '#repositories_failed_count' do
    before do
      create(:geo_project_registry, :sync_failed, project: project_1)
      create(:geo_project_registry, :sync_failed, project: project_3)
      create(:geo_project_registry, :repository_syncing, project: project_4)
      create(:geo_project_registry, :wiki_syncing)
    end

    it 'returns the right number of failed repos with no group restrictions' do
      expect(subject.repositories_failed_count).to eq(2)
    end

    it 'returns the right number of failed repos with group restrictions' do
      secondary.update!(selective_sync_type: 'namespaces', namespaces: [group])

      expect(subject.repositories_failed_count).to eq(1)
    end
  end

  describe '#wikis_failed_count' do
    before do
      create(:geo_project_registry, :sync_failed, project: project_1)
      create(:geo_project_registry, :sync_failed, project: project_3)
      create(:geo_project_registry, :repository_syncing, project: project_4)
      create(:geo_project_registry, :wiki_syncing)
    end

    it 'returns the right number of failed repos with no group restrictions' do
      expect(subject.wikis_failed_count).to eq(2)
    end

    it 'returns the right number of failed repos with group restrictions' do
      secondary.update!(selective_sync_type: 'namespaces', namespaces: [group])

      expect(subject.wikis_failed_count).to eq(1)
    end
  end

  describe '#repositories_synced_in_percentage' do
    it 'returns 0 when no projects are available' do
      expect(subject.repositories_synced_in_percentage).to eq(0)
    end

    it 'returns 0 when project count is unknown' do
      allow(subject).to receive(:projects_count).and_return(nil)

      expect(subject.repositories_synced_in_percentage).to eq(0)
    end

    it 'returns the right percentage with no group restrictions' do
      create(:geo_project_registry, :synced, project: project_1)

      expect(subject.repositories_synced_in_percentage).to be_within(0.0001).of(25)
    end

    it 'returns the right percentage with group restrictions' do
      secondary.update!(selective_sync_type: 'namespaces', namespaces: [group])
      create(:geo_project_registry, :synced, project: project_1)

      expect(subject.repositories_synced_in_percentage).to be_within(0.0001).of(50)
    end
  end

  describe '#wikis_synced_in_percentage' do
    it 'returns 0 when no projects are available' do
      expect(subject.wikis_synced_in_percentage).to eq(0)
    end

    it 'returns 0 when project count is unknown' do
      allow(subject).to receive(:projects_count).and_return(nil)

      expect(subject.wikis_synced_in_percentage).to eq(0)
    end

    it 'returns the right percentage with no group restrictions' do
      create(:geo_project_registry, :synced, project: project_1)

      expect(subject.wikis_synced_in_percentage).to be_within(0.0001).of(25)
    end

    it 'returns the right percentage with group restrictions' do
      secondary.update!(selective_sync_type: 'namespaces', namespaces: [group])
      create(:geo_project_registry, :synced, project: project_1)

      expect(subject.wikis_synced_in_percentage).to be_within(0.0001).of(50)
    end
  end

  describe '#replication_slots_used_count' do
    it 'returns the right number of used replication slots' do
      stub_current_geo_node(primary)
      allow(primary).to receive(:replication_slots_used_count).and_return(1)

      expect(subject.replication_slots_used_count).to eq(1)
    end
  end

  describe '#replication_slots_used_in_percentage' do
    it 'returns 0 when no replication slots are available' do
      expect(subject.replication_slots_used_in_percentage).to eq(0)
    end

    it 'returns 0 when replication slot count is unknown' do
      subject.replication_slots_count = nil

      expect(subject.replication_slots_used_in_percentage).to eq(0)
    end

    it 'returns the right percentage' do
      stub_current_geo_node(primary)
      subject.replication_slots_count = 2
      subject.replication_slots_used_count = 1

      expect(subject.replication_slots_used_in_percentage).to be_within(0.0001).of(50)
    end
  end

  describe '#replication_slots_max_retained_wal_bytes' do
    it 'returns the number of bytes replication slots are using' do
      stub_current_geo_node(primary)
      allow(primary).to receive(:replication_slots_max_retained_wal_bytes).and_return(2.megabytes)

      expect(subject.replication_slots_max_retained_wal_bytes).to eq(2.megabytes)
    end

    it 'handles large values' do
      stub_current_geo_node(primary)
      allow(primary).to receive(:replication_slots_max_retained_wal_bytes).and_return(900.gigabytes)

      expect(subject.replication_slots_max_retained_wal_bytes).to eq(900.gigabytes)
    end
  end

  describe '#repositories_checksummed_count' do
    before do
      stub_current_geo_node(primary)
    end

    it 'returns the right number of checksummed repositories' do
      create(:repository_state, :repository_verified)
      create(:repository_state, :repository_verified)

      expect(subject.repositories_checksummed_count).to eq(2)
    end

    it 'returns existing value when feature flag is off' do
      allow(Gitlab::Geo).to receive(:repository_verification_enabled?).and_return(false)
      create(:geo_node_status, :healthy, geo_node: primary)

      expect(subject.repositories_checksummed_count).to eq(600)
    end
  end

  describe '#repositories_checksum_failed_count' do
    before do
      stub_current_geo_node(primary)
    end

    it 'returns the right number of failed repositories' do
      create(:repository_state, :repository_failed)
      create(:repository_state, :repository_failed)

      expect(subject.repositories_checksum_failed_count).to eq(2)
    end

    it 'returns existing value when feature flag if off' do
      allow(Gitlab::Geo).to receive(:repository_verification_enabled?).and_return(false)
      create(:geo_node_status, :healthy, geo_node: primary)

      expect(subject.repositories_checksum_failed_count).to eq(120)
    end
  end

  describe '#repositories_checksummed_in_percentage' do
    before do
      stub_current_geo_node(primary)
    end

    it 'returns 0 when no projects are available' do
      expect(subject.repositories_checksummed_in_percentage).to eq(0)
    end

    it 'returns 0 when project count is unknown' do
      allow(subject).to receive(:projects_count).and_return(nil)

      expect(subject.repositories_checksummed_in_percentage).to eq(0)
    end

    it 'returns the right percentage' do
      create(:repository_state, :repository_verified, project: project_1)

      expect(subject.repositories_checksummed_in_percentage).to be_within(0.0001).of(25)
    end
  end

  describe '#wikis_checksummed_count' do
    before do
      stub_current_geo_node(primary)
    end

    it 'returns the right number of checksummed wikis' do
      create(:repository_state, :wiki_verified)
      create(:repository_state, :wiki_verified)

      expect(subject.wikis_checksummed_count).to eq(2)
    end

    it 'returns existing value when feature flag if off' do
      allow(Gitlab::Geo).to receive(:repository_verification_enabled?).and_return(false)
      create(:geo_node_status, :healthy, geo_node: primary)

      expect(subject.wikis_checksummed_count).to eq(585)
    end
  end

  describe '#wikis_checksum_failed_count' do
    before do
      stub_current_geo_node(primary)
    end

    it 'returns the right number of failed wikis' do
      create(:repository_state, :wiki_failed)
      create(:repository_state, :wiki_failed)

      expect(subject.wikis_checksum_failed_count).to eq(2)
    end

    it 'returns existing value when feature flag if off' do
      allow(Gitlab::Geo).to receive(:repository_verification_enabled?).and_return(false)
      create(:geo_node_status, :healthy, geo_node: primary)

      expect(subject.wikis_checksum_failed_count).to eq(55)
    end
  end

  describe '#wikis_checksummed_in_percentage' do
    before do
      stub_current_geo_node(primary)
    end

    it 'returns 0 when no projects are available' do
      expect(subject.wikis_checksummed_in_percentage).to eq(0)
    end

    it 'returns 0 when project count is unknown' do
      allow(subject).to receive(:projects_count).and_return(nil)

      expect(subject.wikis_checksummed_in_percentage).to eq(0)
    end

    it 'returns the right percentage' do
      create(:repository_state, :wiki_verified, project: project_1)

      expect(subject.wikis_checksummed_in_percentage).to be_within(0.0001).of(25)
    end
  end

  describe '#container_repositories_count' do
    it 'counts all the repositories' do
      create(:container_repository)
      create(:container_repository)

      expect(subject.container_repositories_count).to eq(2)
    end
  end

  describe '#container_repositories_synced_count' do
    it 'counts synced repositories' do
      create(:container_repository_registry, :synced)
      create(:container_repository_registry, :synced)
      create(:container_repository_registry, :sync_failed)

      expect(subject.container_repositories_synced_count).to eq(2)
    end
  end

  describe '#container_repositories_failed_count' do
    it 'counts failed to sync repositories' do
      create(:container_repository_registry, :synced)
      create(:container_repository_registry, :sync_failed)
      create(:container_repository_registry, :sync_failed)

      expect(subject.container_repositories_failed_count).to eq(2)
    end
  end

  describe '#container_repositories_registry_count' do
    it 'counts number of registries for repositories' do
      create(:container_repository_registry, :synced)
      create(:container_repository_registry, :sync_failed)
      create(:container_repository_registry, :sync_failed)
      create(:container_repository)

      expect(subject.container_repositories_registry_count).to eq(3)
    end
  end

  describe '#container_repositories_synced_in_percentage' do
    let(:container_repository) { create(:container_repository, project: project_1) }

    before do
      create(:container_repository, project: project_1)
      create_list(:container_repository, 2, project: project_3)
    end

    it 'returns 0 when no objects are available' do
      expect(subject.container_repositories_synced_in_percentage).to eq(0)
    end

    it 'returns the right percentage with no group restrictions' do
      create(:container_repository_registry, :synced, container_repository: container_repository)

      expect(subject.container_repositories_synced_in_percentage).to be_within(0.0001).of(25)
    end

    it 'returns the right percentage with group restrictions' do
      secondary.update!(selective_sync_type: 'namespaces', namespaces: [group])
      create(:container_repository_registry, :synced, container_repository: container_repository)

      expect(subject.container_repositories_synced_in_percentage).to be_within(0.0001).of(50)
    end
  end

  describe '#design_repositories_count' do
    it 'counts all the designs' do
      create(:design)
      create(:design)

      expect(subject.design_repositories_count).to eq(2)
    end
  end

  describe '#design_repositories_synced_count' do
    it 'counts synced repositories' do
      create(:geo_design_registry, :synced)
      create(:geo_design_registry, :sync_failed)

      expect(subject.design_repositories_synced_count).to eq(1)
    end
  end

  describe '#design_repositories_failed_count' do
    it 'counts failed to sync repositories' do
      create(:geo_design_registry, :sync_failed)
      create(:geo_design_registry, :synced)

      expect(subject.design_repositories_failed_count).to eq(1)
    end
  end

  describe '#design_repositories_registry_count' do
    it 'counts number of registries for repositories' do
      create(:geo_design_registry, :sync_failed)
      create(:geo_design_registry)
      create(:geo_design_registry, :synced)

      expect(subject.design_repositories_registry_count).to eq(3)
    end
  end

  describe '#design_repositories_synced_in_percentage' do
    it 'returns 0 when no objects are available' do
      expect(subject.design_repositories_synced_in_percentage).to eq(0)
    end

    it 'returns the right percentage with no group restrictions' do
      create(:geo_design_registry, :synced)
      create(:geo_design_registry, :sync_failed)

      expect(subject.design_repositories_synced_in_percentage).to be_within(0.0001).of(50)
    end

    it 'returns the right percentage with group restrictions' do
      secondary.update!(selective_sync_type: 'namespaces', namespaces: [group])

      create(:geo_design_registry, :synced, project: project_1)
      create(:geo_design_registry, :sync_failed, project: project_2)
      create(:geo_design_registry, :sync_failed, project: project_3)
      create(:geo_design_registry, :sync_failed, project: project_4)

      expect(subject.design_repositories_synced_in_percentage).to be_within(0.0001).of(50)
    end
  end

  describe '#repositories_verified_count' do
    before do
      stub_current_geo_node(secondary)
    end

    it 'returns the right number of verified repositories' do
      create(:geo_project_registry, :repository_verified)
      create(:geo_project_registry, :repository_verified)

      expect(subject.repositories_verified_count).to eq(2)
    end

    it 'returns existing value when feature flag if off' do
      allow(Gitlab::Geo).to receive(:repository_verification_enabled?).and_return(false)
      create(:geo_node_status, :healthy, geo_node: secondary)

      expect(subject.repositories_verified_count).to eq(501)
    end
  end

  describe '#repositories_checksum_mismatch_count' do
    before do
      stub_current_geo_node(secondary)
    end

    it 'returns the right number of repositories that checksum mismatch' do
      create(:geo_project_registry, :repository_checksum_mismatch)
      create(:geo_project_registry, :repository_verification_failed)
      create(:geo_project_registry, :repository_verified)

      expect(subject.repositories_checksum_mismatch_count).to eq(1)
    end

    it 'returns existing value when feature flag if off' do
      allow(Gitlab::Geo).to receive(:repository_verification_enabled?).and_return(false)
      create(:geo_node_status, :healthy, geo_node: secondary)

      expect(subject.repositories_checksum_mismatch_count).to eq(15)
    end
  end

  describe '#repositories_verification_failed_count' do
    before do
      stub_current_geo_node(secondary)
    end

    it 'returns the right number of failed repositories' do
      create(:geo_project_registry, :repository_verification_failed)
      create(:geo_project_registry, :repository_verification_failed)

      expect(subject.repositories_verification_failed_count).to eq(2)
    end

    it 'returns existing value when feature flag if off' do
      allow(Gitlab::Geo).to receive(:repository_verification_enabled?).and_return(false)
      create(:geo_node_status, :healthy, geo_node: secondary)

      expect(subject.repositories_verification_failed_count).to eq(100)
    end
  end

  describe '#repositories_retrying_verification_count' do
    before do
      stub_current_geo_node(secondary)
    end

    it 'returns the right number of repositories retrying verification' do
      create(:geo_project_registry, :repository_verification_failed, repository_verification_retry_count: 1)
      create(:geo_project_registry, :repository_verification_failed, repository_verification_retry_count: nil)
      create(:geo_project_registry, :repository_verified)

      expect(subject.repositories_retrying_verification_count).to eq(1)
    end

    it 'returns existing value when feature flag if off' do
      allow(Gitlab::Geo).to receive(:repository_verification_enabled?).and_return(false)
      create(:geo_node_status, :healthy, geo_node: secondary)

      expect(subject.repositories_retrying_verification_count).to eq(25)
    end
  end

  describe '#wikis_verified_count' do
    before do
      stub_current_geo_node(secondary)
    end

    it 'returns the right number of verified wikis' do
      create(:geo_project_registry, :wiki_verified)
      create(:geo_project_registry, :wiki_verified)

      expect(subject.wikis_verified_count).to eq(2)
    end

    it 'returns existing value when feature flag if off' do
      allow(Gitlab::Geo).to receive(:repository_verification_enabled?).and_return(false)
      create(:geo_node_status, :healthy, geo_node: secondary)

      expect(subject.wikis_verified_count).to eq(499)
    end
  end

  describe '#wikis_checksum_mismatch_count' do
    before do
      stub_current_geo_node(secondary)
    end

    it 'returns the right number of wikis that checksum mismatch' do
      create(:geo_project_registry, :wiki_checksum_mismatch)
      create(:geo_project_registry, :wiki_verification_failed)
      create(:geo_project_registry, :wiki_verified)

      expect(subject.wikis_checksum_mismatch_count).to eq(1)
    end

    it 'returns existing value when feature flag if off' do
      allow(Gitlab::Geo).to receive(:repository_verification_enabled?).and_return(false)
      create(:geo_node_status, :healthy, geo_node: secondary)

      expect(subject.wikis_checksum_mismatch_count).to eq(10)
    end
  end

  describe '#wikis_verification_failed_count' do
    before do
      stub_current_geo_node(secondary)
    end

    it 'returns the right number of failed wikis' do
      create(:geo_project_registry, :wiki_verification_failed)
      create(:geo_project_registry, :wiki_verification_failed)

      expect(subject.wikis_verification_failed_count).to eq(2)
    end

    it 'returns existing value when feature flag if off' do
      allow(Gitlab::Geo).to receive(:repository_verification_enabled?).and_return(false)
      create(:geo_node_status, :healthy, geo_node: secondary)

      expect(subject.wikis_verification_failed_count).to eq(99)
    end
  end

  describe '#wikis_retrying_verification_count' do
    before do
      stub_current_geo_node(secondary)
    end

    it 'returns the right number of wikis retrying verification' do
      create(:geo_project_registry, :wiki_verification_failed, wiki_verification_retry_count: 1)
      create(:geo_project_registry, :wiki_verification_failed, wiki_verification_retry_count: nil)
      create(:geo_project_registry, :wiki_verified)

      expect(subject.wikis_retrying_verification_count).to eq(1)
    end

    it 'returns existing value when feature flag if off' do
      allow(Gitlab::Geo).to receive(:repository_verification_enabled?).and_return(false)
      create(:geo_node_status, :healthy, geo_node: secondary)

      expect(subject.wikis_retrying_verification_count).to eq(3)
    end
  end

  describe '#last_event_id and #last_event_date' do
    it 'returns nil when no events are available' do
      expect(subject.last_event_id).to be_nil
      expect(subject.last_event_date).to be_nil
    end

    it 'returns the latest event' do
      created_at = Date.today.to_time(:utc)
      event = create(:geo_event_log, created_at: created_at)

      expect(subject.last_event_id).to eq(event.id)
      expect(subject.last_event_date).to eq(created_at)
    end
  end

  describe '#cursor_last_event_id and #cursor_last_event_date' do
    it 'returns nil when no events are available' do
      expect(subject.cursor_last_event_id).to be_nil
      expect(subject.cursor_last_event_date).to be_nil
    end

    it 'returns the latest event ID if secondary' do
      allow(Gitlab::Geo).to receive(:secondary?).and_return(true)
      event = create(:geo_event_log_state)

      expect(subject.cursor_last_event_id).to eq(event.event_id)
    end

    it "doesn't attempt to retrieve cursor if primary" do
      stub_current_geo_node(primary)
      create(:geo_event_log_state)

      expect(subject.cursor_last_event_date).to eq(nil)
      expect(subject.cursor_last_event_id).to eq(nil)
    end
  end

  describe '#version' do
    it { expect(status.version).to eq(Gitlab::VERSION) }
  end

  describe '#revision' do
    it { expect(status.revision).to eq(Gitlab.revision) }
  end

  describe '#[]' do
    it 'returns values for each attribute' do
      expect(subject[:projects_count]).to eq(4)
      expect(subject[:repositories_synced_count]).to eq(0)
    end

    it 'raises an error for invalid attributes' do
      expect { subject[:testme] }.to raise_error(NoMethodError)
    end
  end

  shared_examples 'timestamp parameters' do |timestamp_column, date_column|
    it 'returns the value it was assigned via UNIX timestamp' do
      now = Time.now.beginning_of_day.utc
      subject.update_attribute(timestamp_column, now.to_i)

      expect(subject.public_send(date_column)).to eq(now)
      expect(subject.public_send(timestamp_column)).to eq(now.to_i)
    end
  end

  describe '#last_successful_status_check_timestamp' do
    it_behaves_like 'timestamp parameters', :last_successful_status_check_timestamp, :last_successful_status_check_at
  end

  describe '#last_event_timestamp' do
    it_behaves_like 'timestamp parameters', :last_event_timestamp, :last_event_date
  end

  describe '#cursor_last_event_timestamp' do
    it_behaves_like 'timestamp parameters', :cursor_last_event_timestamp, :cursor_last_event_date
  end

  describe '#storage_shards' do
    it "returns the current node's shard config" do
      expect(subject[:storage_shards].as_json).to eq(StorageShard.all.as_json)
    end
  end

  describe '#from_json' do
    it 'returns a new GeoNodeStatus excluding parameters' do
      status = create(:geo_node_status)

      data = GeoNodeStatusSerializer.new.represent(status).as_json
      data['id'] = 10000

      result = described_class.from_json(data)

      expect(result.id).to be_nil
      expect(result.attachments_count).to eq(status.attachments_count)
      expect(result.cursor_last_event_date).to eq(Time.at(status.cursor_last_event_timestamp))
      expect(result.storage_shards.count).to eq(Settings.repositories.storages.count)
    end
  end

  describe '#storage_shards_match?' do
    it 'returns false if no shard data is available for secondary' do
      stub_primary_node
      stub_current_geo_node(secondary)

      status = create(:geo_node_status, geo_node: secondary, storage_configuration_digest: 'bc11119c101846c20367fff34ce9fffa9b05aab8')

      expect(status.storage_shards_match?).to be false
    end

    it 'returns true even if no shard data is available for secondary' do
      stub_secondary_node
      stub_current_geo_node(primary)

      status = create(:geo_node_status, geo_node: primary, storage_configuration_digest: 'bc11119c101846c20367fff34ce9fffa9b05aab8')

      expect(status.storage_shards_match?).to be true
    end

    it 'returns false if the storage shards do not match' do
      stub_primary_node
      stub_current_geo_node(secondary)
      create(:geo_node_status, geo_node: primary, storage_configuration_digest: 'aea7849c10b886c202676ff34ce9fdf0940567b8')

      status = create(:geo_node_status, geo_node: secondary, storage_configuration_digest: 'bc11119c101846c20367fff34ce9fffa9b05aab8')

      expect(status.storage_shards_match?).to be false
    end
  end

  describe '#repositories_checked_count' do
    before do
      stub_application_setting(repository_checks_enabled: true)
    end

    context 'current is a Geo primary' do
      before do
        stub_current_geo_node(primary)
      end

      it 'counts the number of repo checked projects' do
        project_1.update!(last_repository_check_at: 2.minutes.ago)
        project_2.update!(last_repository_check_at: 7.minutes.ago)

        expect(status.repositories_checked_count).to eq(2)
      end
    end

    context 'current is a Geo secondary' do
      before do
        stub_current_geo_node(secondary)
      end

      it 'counts the number of repo checked projects' do
        create(:geo_project_registry, project: project_1, last_repository_check_at: 2.minutes.ago)
        create(:geo_project_registry, project: project_2, last_repository_check_at: 7.minutes.ago)
        create(:geo_project_registry, project: project_3)

        expect(status.repositories_checked_count).to eq(2)
      end
    end
  end

  describe '#repositories_checked_failed_count' do
    before do
      stub_application_setting(repository_checks_enabled: true)
    end

    context 'current is a Geo primary' do
      before do
        stub_current_geo_node(primary)
      end

      it 'counts the number of repo check failed projects' do
        project_1.update!(last_repository_check_at: 2.minutes.ago, last_repository_check_failed: true)
        project_2.update!(last_repository_check_at: 7.minutes.ago, last_repository_check_failed: false)

        expect(status.repositories_checked_failed_count).to eq(1)
      end
    end

    context 'current is a Geo secondary' do
      before do
        stub_current_geo_node(secondary)
      end

      it 'counts the number of repo check failed projects' do
        create(:geo_project_registry, project: project_1, last_repository_check_at: 2.minutes.ago, last_repository_check_failed: true)
        create(:geo_project_registry, project: project_2, last_repository_check_at: 7.minutes.ago, last_repository_check_failed: false)
        create(:geo_project_registry, project: project_3)

        expect(status.repositories_checked_failed_count).to eq(1)
      end
    end
  end

  describe '#load_data_from_current_node' do
    context 'on the primary' do
      before do
        stub_current_geo_node(primary)
      end

      it 'does not call LfsObjectRegistryFinder#count_syncable' do
        expect_any_instance_of(Geo::LfsObjectRegistryFinder).not_to receive(:count_syncable)

        subject
      end

      it 'does not call AttachmentRegistryFinder#count_syncable' do
        expect_any_instance_of(Geo::AttachmentRegistryFinder).not_to receive(:count_syncable)

        subject
      end

      it 'does not call JobArtifactRegistryFinder#count_syncable' do
        expect_any_instance_of(Geo::JobArtifactRegistryFinder).not_to receive(:count_syncable)

        subject
      end
    end

    context 'on the secondary' do
      it 'calls LfsObjectRegistryFinder#count_syncable' do
        expect_any_instance_of(Geo::LfsObjectRegistryFinder).to receive(:count_syncable)

        subject
      end

      it 'calls AttachmentRegistryFinder#count_syncable' do
        expect_any_instance_of(Geo::AttachmentRegistryFinder).to receive(:count_syncable)

        subject
      end

      it 'calls JobArtifactRegistryFinder#count_syncable' do
        expect_any_instance_of(Geo::JobArtifactRegistryFinder).to receive(:count_syncable)

        subject
      end
    end
  end
end
