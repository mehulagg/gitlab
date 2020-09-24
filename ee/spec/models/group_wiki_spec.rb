# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupWiki do
  it_behaves_like 'wiki model' do
    let(:wiki_container) { create(:group, :wiki_repo) }
    let(:wiki_container_without_repo) { create(:group) }

    before do
      wiki_container.add_owner(user)
    end

    describe '#create_wiki_repository' do
      before do
        # Don't actually create the repository, because we're using storage shards that don't exist.
        allow(subject.repository).to receive(:create_if_not_exists)
        allow(subject).to receive(:repository_exists?).and_return(true)
      end

      context 'when a tracking entry does not exist' do
        let(:wiki_container) { wiki_container_without_repo }

        it 'creates a new entry' do
          expect { subject.create_wiki_repository }.to change(wiki_container, :group_wiki_repository)
            .from(nil).to(kind_of(GroupWikiRepository))
        end

        it 'tracks the storage location' do
          expect(subject).to receive(:repository_storage).and_return('foo')

          subject.create_wiki_repository

          expect(wiki_container.group_wiki_repository).to have_attributes(
            disk_path: subject.storage.disk_path,
            shard_name: 'foo'
          )
        end
      end

      context 'when a tracking entry exists' do
        it 'does not create a new entry in the database' do
          expect { subject.create_wiki_repository }.not_to change(wiki_container, :group_wiki_repository)
        end

        it 'updates the storage location' do
          expect(subject).to receive(:repository_storage).and_return('foo')
          expect(subject.storage).to receive(:disk_path).and_return('fancy/new/path')

          subject.create_wiki_repository

          expect(wiki_container.group_wiki_repository).to have_attributes(
            disk_path: 'fancy/new/path',
            shard_name: 'foo'
          )
        end
      end
    end

    describe '#storage' do
      it 'uses the group repository prefix' do
        expect(subject.storage.base_dir).to start_with('@groups/')
      end
    end

    describe '#repository_storage' do
      context 'when a tracking entry does not exist' do
        let(:wiki_container) { wiki_container_without_repo }

        it 'returns the default shard' do
          expect(subject.repository_storage).to eq('default')
        end
      end

      context 'when a tracking entry exists' do
        it 'returns the persisted shard if the repository is tracked' do
          expect(wiki_container.group_wiki_repository).to receive(:shard_name).and_return('foo')
          expect(subject.repository_storage).to eq('foo')
        end
      end
    end

    describe '#hashed_storage?' do
      it 'returns true' do
        expect(subject.hashed_storage?).to be(true)
      end
    end

    describe '#disk_path' do
      it 'returns the repository storage path' do
        expect(subject.disk_path).to eq("#{subject.storage.disk_path}.wiki")
      end
    end
  end

  it_behaves_like 'EE wiki model' do
    let(:wiki_container) { create(:group, :wiki_repo) }

    before do
      wiki_container.add_owner(user)
    end

    it 'does not use Elasticsearch' do
      expect(subject).not_to be_a(Elastic::WikiRepositoriesSearch)
    end
  end
end
