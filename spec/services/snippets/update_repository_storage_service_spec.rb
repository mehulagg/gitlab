# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Snippets::UpdateRepositoryStorageService do
  include Gitlab::ShellAdapter

  subject { described_class.new(repository_storage_move) }

  describe "#execute" do
    let(:time) { Time.current }
    let_it_be_with_reload(:snippet) { create(:snippet, :repository) }
    let_it_be_with_reload(:repository_storage_move) { create(:snippet_repository_storage_move, :scheduled, container: snippet, destination_storage_name: destination) }
    let(:destination) { 'test_second_storage' }
    let!(:checksum) { snippet.repository.checksum }
    let(:snippet_repository_double) { double(:repository) }
    let(:original_snippet_repository_double) { double(:repository) }

    before do
      allow(Time).to receive(:now).and_return(time)
      allow(Gitlab.config.repositories.storages).to receive(:keys).and_return(%w[default test_second_storage])
      allow(Gitlab::GitalyClient).to receive(:filesystem_id).with('default').and_call_original
      allow(Gitlab::GitalyClient).to receive(:filesystem_id).with('test_second_storage').and_return(SecureRandom.uuid)
      allow(Gitlab::Git::Repository).to receive(:new).and_call_original
      allow(Gitlab::Git::Repository).to receive(:new)
        .with('test_second_storage', snippet.repository.raw.relative_path, snippet.repository.gl_repository, snippet.repository.full_path)
        .and_return(snippet_repository_double)
      allow(Gitlab::Git::Repository).to receive(:new)
        .with('default', snippet.repository.raw.relative_path, nil, nil)
        .and_return(original_snippet_repository_double)
    end

    context 'when the move succeeds' do
      it 'moves the repository to the new storage and unmarks the repository as read only' do
        old_path = Gitlab::GitalyClient::StorageSettings.allow_disk_access do
          snippet.repository.path_to_repo
        end

        expect(snippet_repository_double).to receive(:replicate)
          .with(snippet.repository.raw)
        expect(snippet_repository_double).to receive(:checksum)
          .and_return(checksum)
        expect(original_snippet_repository_double).to receive(:remove)

        result = subject.execute
        snippet.reload

        expect(result).to be_success
        expect(snippet).not_to be_repository_read_only
        expect(snippet.repository_storage).to eq('test_second_storage')
        expect(gitlab_shell.repository_exists?('default', old_path)).to be(false)
        expect(snippet.snippet_repository.shard_name).to eq('test_second_storage')
      end
    end

    context 'when the filesystems are the same' do
      let(:destination) { snippet.repository_storage }

      it 'bails out and does nothing' do
        result = subject.execute

        expect(result).to be_error
        expect(result.message).to match(/SameFilesystemError/)
      end
    end

    context 'when the move fails' do
      it 'unmarks the repository as read-only without updating the repository storage' do
        allow(Gitlab::GitalyClient).to receive(:filesystem_id).with('default').and_call_original
        allow(Gitlab::GitalyClient).to receive(:filesystem_id).with('test_second_storage').and_return(SecureRandom.uuid)

        expect(snippet_repository_double).to receive(:replicate)
          .with(snippet.repository.raw)
          .and_raise(Gitlab::Git::CommandError)

        result = subject.execute

        expect(result).to be_error
        expect(snippet).not_to be_repository_read_only
        expect(snippet.repository_storage).to eq('default')
        expect(repository_storage_move).to be_failed
      end
    end

    context 'when the cleanup fails' do
      it 'sets the correct state' do
        expect(snippet_repository_double).to receive(:replicate)
          .with(snippet.repository.raw)
        expect(snippet_repository_double).to receive(:checksum)
          .and_return(checksum)
        expect(original_snippet_repository_double).to receive(:remove)
          .and_raise(Gitlab::Git::CommandError)

        result = subject.execute

        expect(result).to be_error
        expect(repository_storage_move).to be_cleanup_failed
      end
    end

    context 'when the checksum does not match' do
      it 'unmarks the repository as read-only without updating the repository storage' do
        allow(Gitlab::GitalyClient).to receive(:filesystem_id).with('default').and_call_original
        allow(Gitlab::GitalyClient).to receive(:filesystem_id).with('test_second_storage').and_return(SecureRandom.uuid)

        expect(snippet_repository_double).to receive(:replicate)
          .with(snippet.repository.raw)
        expect(snippet_repository_double).to receive(:checksum)
          .and_return('not matching checksum')

        result = subject.execute

        expect(result).to be_error
        expect(snippet).not_to be_repository_read_only
        expect(snippet.repository_storage).to eq('default')
      end
    end

    context 'when the repository move is finished' do
      let(:repository_storage_move) { create(:snippet_repository_storage_move, :finished, container: snippet, destination_storage_name: destination) }

      it 'is idempotent' do
        expect do
          result = subject.execute

          expect(result).to be_success
        end.not_to change(repository_storage_move, :state)
      end
    end

    context 'when the repository move is failed' do
      let(:repository_storage_move) { create(:snippet_repository_storage_move, :failed, container: snippet, destination_storage_name: destination) }

      it 'is idempotent' do
        expect do
          result = subject.execute

          expect(result).to be_success
        end.not_to change(repository_storage_move, :state)
      end
    end
  end
end
