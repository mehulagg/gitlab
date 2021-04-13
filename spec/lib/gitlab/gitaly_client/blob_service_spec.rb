# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::GitalyClient::BlobService do
  let(:project) { create(:project, :repository) }
  let(:storage_name) { project.repository_storage }
  let(:relative_path) { project.disk_path + '.git' }
  let(:repository) { project.repository }
  let(:client) { described_class.new(repository) }

  describe '#batch_lfs_pointers' do
    let(:blob_ids) { ["4206f951d2691c78aac4c0ce9f2b23580b2c92cdcc4336e1028742c0274938e0"] }
    let(:expected_params) do
      { blob_ids: blob_ids }
    end

    subject { client.batch_lfs_pointers(blob_ids) }

    it 'sends a get_lfs_pointers message' do
      expect_any_instance_of(Gitaly::BlobService::Stub)
        .to receive(:get_lfs_pointers)
        .with(gitaly_request_with_params(expected_params), kind_of(Hash))
        .and_return([])

      subject
    end
  end

  describe '#get_new_lfs_pointers' do
    let(:revision) { 'master' }
    let(:limit) { 5 }
    let(:not_in) { %w[branch-a branch-b] }
    let(:expected_params) do
      { revision: revision, limit: limit, not_in_refs: not_in, not_in_all: false }
    end

    subject { client.get_new_lfs_pointers(revision, limit, not_in) }

    it 'sends a get_new_lfs_pointers message' do
      expect_any_instance_of(Gitaly::BlobService::Stub)
        .to receive(:get_new_lfs_pointers)
        .with(gitaly_request_with_params(expected_params), kind_of(Hash))
        .and_return([])

      subject
    end

    context 'with not_in = :all' do
      let(:not_in) { :all }
      let(:expected_params) do
        { revision: revision, limit: limit, not_in_refs: [], not_in_all: true }
      end

      it 'sends the correct message' do
        expect_any_instance_of(Gitaly::BlobService::Stub)
          .to receive(:get_new_lfs_pointers)
          .with(gitaly_request_with_params(expected_params), kind_of(Hash))
          .and_return([])

        subject
      end
    end

    context 'with hook environment' do
      let(:git_env) do
        {
          'GIT_OBJECT_DIRECTORY_RELATIVE' => '.git/objects',
          'GIT_ALTERNATE_OBJECT_DIRECTORIES_RELATIVE' => ['/dir/one', '/dir/two']
        }
      end

      let(:expected_params) do
        expected_repository = repository.gitaly_repository
        expected_repository.git_alternate_object_directories = Google::Protobuf::RepeatedField.new(:string)

        { limit: limit, repository: expected_repository }
      end

      it 'sends a list_all_lfs_pointers message' do
        allow(Gitlab::Git::HookEnv).to receive(:all).with(repository.gl_repository).and_return(git_env)

        expect_any_instance_of(Gitaly::BlobService::Stub)
          .to receive(:list_all_lfs_pointers)
          .with(gitaly_request_with_params(expected_params), kind_of(Hash))
          .and_return([])

        subject
      end
    end
  end

  describe '#get_all_lfs_pointers' do
    subject { client.get_all_lfs_pointers }

    it 'sends a get_all_lfs_pointers message' do
      expect_any_instance_of(Gitaly::BlobService::Stub)
        .to receive(:get_all_lfs_pointers)
        .with(gitaly_request_with_params({}), kind_of(Hash))
        .and_return([])

      subject
    end
  end
end
