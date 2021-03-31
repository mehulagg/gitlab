# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::GitalyClient::BlobService do
  let(:project) { create(:project, :repository) }
  let(:storage_name) { project.repository_storage }
  let(:relative_path) { project.disk_path + '.git' }
  let(:repository) { project.repository }
  let(:client) { described_class.new(repository) }

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
  end

  describe '#list_all_lfs_pointers' do
    let(:limit) { 5 }
    let(:git_object_directory) { '.git/objects' }
    let(:git_alternate_object_directory) { ['/dir/one', '/dir/two'] }
    let(:git_env) do
      {
        'GIT_OBJECT_DIRECTORY_RELATIVE' => git_object_directory,
        'GIT_ALTERNATE_OBJECT_DIRECTORIES_RELATIVE' => git_alternate_object_directory
      }
    end

    subject { client.list_all_lfs_pointers(limit, only_object_dir) }

    shared_examples 'a request' do
      it 'sends a list_all_lfs_pointers message' do
        allow(Gitlab::Git::HookEnv).to receive(:all).with(repository.gl_repository).and_return(git_env)

        expect_any_instance_of(Gitaly::BlobService::Stub)
          .to receive(:list_all_lfs_pointers)
          .with(gitaly_request_with_params(expected_params), kind_of(Hash))
          .and_return([])

        subject
      end
    end

    context 'with object dir' do
      let(:only_object_dir) { false }
      let(:expected_params) do
        {
          limit: limit,
          repository: repository.gitaly_repository
        }
      end

      include_examples 'a request'
    end

    context 'without object dir' do
      let(:only_object_dir) { true }
      let(:expected_params) do
        expected_repository = repository.gitaly_repository
        expected_repository.git_alternate_object_directories = Google::Protobuf::RepeatedField.new(:string)

        {
          limit: limit,
          repository: expected_repository
        }
      end

      include_examples 'a request'
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
