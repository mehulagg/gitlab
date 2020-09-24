# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::ProjectSyncWorker do
  describe '#perform' do
    let(:project) { create(:project) }
    let(:project_with_broken_storage) { create(:project, :broken_storage) }
    let(:repository_sync_service) { spy }
    let(:wiki_sync_service) { spy }

    before do
      allow(Gitlab::ShardHealthCache).to receive(:healthy_shard?)
        .with(project.repository_storage).once.and_return(true)

      allow(Gitlab::ShardHealthCache).to receive(:healthy_shard?)
        .with(project_with_broken_storage.repository_storage).once.and_return(false)

      allow(Geo::RepositorySyncService).to receive(:new)
        .with(instance_of(Project)).once.and_return(repository_sync_service)

      allow(Geo::WikiSyncService).to receive(:new)
        .with(instance_of(Project)).once.and_return(wiki_sync_service)
    end

    context 'when project could not be found' do
      it 'logs an error and returns' do
        expect(subject).to receive(:log_error).with("Couldn't find project, skipping syncing", project_id: non_existing_record_id)

        expect { subject.perform(non_existing_record_id) }.not_to raise_error
      end
    end

    context 'when the shard associated to the project is unhealthy' do
      it 'logs an error and returns' do
        expect(subject).to receive(:log_error).with("Project shard '#{project_with_broken_storage.repository_storage}' is unhealthy, skipping syncing", project_id: project_with_broken_storage.id)
        expect(repository_sync_service).not_to receive(:execute)
        expect(wiki_sync_service).not_to receive(:execute)

        subject.perform(project_with_broken_storage.id)
      end
    end

    context 'when project repositories has never been synced' do
      it 'performs Geo::RepositorySyncService for the given project' do
        subject.perform(project.id, sync_repository: true)

        expect(repository_sync_service).to have_received(:execute).once
        expect(wiki_sync_service).not_to have_received(:execute)
      end

      it 'performs Geo::WikiSyncService for the given project' do
        subject.perform(project.id, sync_wiki: true)

        expect(wiki_sync_service).to have_received(:execute).once
        expect(repository_sync_service).not_to have_received(:execute)
      end
    end

    context 'when project repositories has been synced' do
      let!(:registry) { create(:geo_project_registry, :synced, project: project) }

      it 'does not perform Geo::RepositorySyncService for the given project' do
        subject.perform(project.id, sync_repository: true)

        expect(repository_sync_service).not_to have_received(:execute)
      end

      it 'does not perform Geo::WikiSyncService for the given project' do
        subject.perform(project.id, sync_wiki: true)

        expect(wiki_sync_service).not_to have_received(:execute)
      end
    end

    context 'when last attempt to sync project repositories failed' do
      let!(:registry) { create(:geo_project_registry, :sync_failed, project: project) }

      it 'performs Geo::RepositorySyncService for the given project' do
        subject.perform(project.id, sync_repository: true)

        expect(repository_sync_service).to have_received(:execute).once
      end

      it 'performs Geo::WikiSyncService for the given project' do
        subject.perform(project.id, sync_wiki: true)

        expect(wiki_sync_service).to have_received(:execute).once
      end
    end
  end
end
