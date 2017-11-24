require 'spec_helper'

RSpec.describe Geo::WikiSyncService do
  include ::EE::GeoHelpers

  set(:primary) { create(:geo_node, :primary, host: 'primary-geo-node', relative_url_root: '/gitlab') }
  set(:secondary) { create(:geo_node) }

  let(:lease) { double(try_obtain: true) }

  subject { described_class.new(project) }

  before do
    stub_current_geo_node(secondary)
  end

  it_behaves_like 'geo base sync execution'

  describe '#execute' do
    let(:project) { create(:project_empty_repo) }
    let(:repository) { project.wiki.repository }
    let(:url_to_repo) { "#{primary.url}/#{project.full_path}.wiki.git" }

    before do
      allow(Gitlab::ExclusiveLease).to receive(:new)
        .with(subject.lease_key, anything)
        .and_return(lease)

      allow_any_instance_of(Repository).to receive(:fetch_as_mirror)
        .and_return(true)
    end

    it 'fetches wiki repository with JWT credentials' do
      expect(repository).to receive(:with_config).with("http.#{url_to_repo}.extraHeader" => anything).and_call_original
      expect(repository).to receive(:fetch_as_mirror).with(url_to_repo, forced: true).once

      subject.execute
    end

    it 'releases lease' do
      expect(Gitlab::ExclusiveLease).to receive(:cancel).once.with(
        subject.__send__(:lease_key), anything).and_call_original

      subject.execute
    end

    it 'does not fetch wiki repository if cannot obtain a lease' do
      allow(lease).to receive(:try_obtain) { false }

      expect(repository).not_to receive(:fetch_as_mirror)

      subject.execute
    end

    it 'rescues exception when Gitlab::Shell::Error is raised' do
      allow(repository).to receive(:fetch_as_mirror).with(url_to_repo, forced: true) { raise Gitlab::Shell::Error }

      expect { subject.execute }.not_to raise_error
    end

    it 'rescues exception when Gitlab::Git::RepositoryMirroring::RemoteError is raised' do
      allow(repository).to receive(:fetch_as_mirror).with(url_to_repo, forced: true)
        .and_raise(Gitlab::Git::RepositoryMirroring::RemoteError)

      expect { subject.execute }.not_to raise_error
    end

    it 'rescues exception when Gitlab::Git::Repository::NoRepository is raised' do
      allow(repository).to receive(:fetch_as_mirror).with(url_to_repo, forced: true) { raise Gitlab::Git::Repository::NoRepository }

      expect { subject.execute }.not_to raise_error
    end

    context 'tracking database' do
      it 'creates a new registry if does not exists' do
        expect { subject.execute }.to change(Geo::ProjectRegistry, :count).by(1)
      end

      it 'does not create a new registry if one exists' do
        create(:geo_project_registry, project: project)

        expect { subject.execute }.not_to change(Geo::ProjectRegistry, :count)
      end

      context 'when repository sync succeed' do
        let(:registry) { Geo::ProjectRegistry.find_by(project_id: project.id) }

        it 'sets last_wiki_synced_at' do
          subject.execute

          expect(registry.last_wiki_synced_at).not_to be_nil
        end

        it 'sets last_wiki_successful_sync_at' do
          subject.execute

          expect(registry.last_wiki_successful_sync_at).not_to be_nil
        end

        it 'logs success with timings' do
          allow(Gitlab::Geo::Logger).to receive(:info).and_call_original
          expect(Gitlab::Geo::Logger).to receive(:info).with(hash_including(:message, :update_delay_s, :download_time_s)).and_call_original

          subject.execute
        end
      end

      context 'when wiki sync fail' do
        let(:registry) { Geo::ProjectRegistry.find_by(project_id: project.id) }

        before do
          allow(repository).to receive(:fetch_as_mirror).with(url_to_repo, forced: true) { raise Gitlab::Shell::Error }

          subject.execute
        end

        it 'sets last_wiki_synced_at' do
          expect(registry.last_wiki_synced_at).not_to be_nil
        end

        it 'resets last_wiki_successful_sync_at' do
          expect(registry.last_wiki_successful_sync_at).to be_nil
        end
      end
    end

    context 'secondary replicates over SSH' do
      set(:ssh_secondary) { create(:geo_node, :ssh) }

      let(:url_to_repo) { "#{primary.clone_url_prefix}/#{project.full_path}.wiki.git" }

      before do
        stub_current_geo_node(ssh_secondary)
      end

      it 'fetches wiki repository over SSH' do
        expect(repository).to receive(:fetch_as_mirror).with(url_to_repo, forced: true).once

        subject.execute
      end
    end
  end
end
