# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Git::ObjectPool do
  let(:pool_repository) { create(:pool_repository) }
  let(:source_repository) { pool_repository.source_project.repository }

  subject { pool_repository.object_pool }

  describe '#storage' do
    it "equals the pool repository's shard name" do
      expect(subject.storage).not_to be_nil
      expect(subject.storage).to eq(pool_repository.shard_name)
    end
  end

  describe '#create' do
    before do
      subject.create
    end

    context "when the pool doesn't exist yet" do
      it 'creates the pool' do
        expect(subject.exists?).to be(true)
      end
    end

    context 'when the pool already exists' do
      it 'raises an FailedPrecondition' do
        expect do
          subject.create
        end.to raise_error(GRPC::FailedPrecondition)
      end
    end
  end

  describe '#exists?' do
    context "when the object pool doesn't exist" do
      it 'returns false' do
        expect(subject.exists?).to be(false)
      end
    end

    context 'when the object pool exists' do
      let(:pool) { create(:pool_repository, :ready) }

      subject { pool.object_pool }

      it 'returns true' do
        expect(subject.exists?).to be(true)
      end
    end
  end

  describe '#link' do
    let!(:pool_repository) { create(:pool_repository, :ready) }

    context 'when no remotes are set' do
      it 'sets a remote' do
        subject.link(source_repository)

        repo = Gitlab::GitalyClient::StorageSettings.allow_disk_access do
          Rugged::Repository.new(subject.repository.path)
        end

        expect(repo.remotes.count).to be(1)
        expect(repo.remotes.first.name).to eq(source_repository.object_pool_remote_name)
      end
    end

    context 'when the remote is already set' do
      before do
        subject.link(source_repository)
      end

      it "doesn't raise an error" do
        subject.link(source_repository)

        repo = Gitlab::GitalyClient::StorageSettings.allow_disk_access do
          Rugged::Repository.new(subject.repository.path)
        end

        expect(repo.remotes.count).to be(1)
        expect(repo.remotes.first.name).to eq(source_repository.object_pool_remote_name)
      end
    end
  end
end
