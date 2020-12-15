# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Snippets::ScheduleBulkRepositoryShardMovesService do
  before do
    stub_storage_settings('test_second_storage' => { 'path' => 'tmp/tests/extra_storage' })
  end

  let!(:snippet) { create(:snippet, :repository).tap { |snippet| snippet.create_repository } }
  let(:source_storage_name) { 'default' }
  let(:destination_storage_name) { 'test_second_storage' }

  describe '#execute' do
    it 'schedules snippet repository storage moves' do
      expect { subject.execute(source_storage_name, destination_storage_name) }
        .to change(SnippetRepositoryStorageMove, :count).by(1)

      storage_move = snippet.repository_storage_moves.last!

      expect(storage_move).to have_attributes(
        source_storage_name: source_storage_name,
        destination_storage_name: destination_storage_name,
        state_name: :scheduled
      )
    end

    context 'read-only repository' do
      let!(:snippet) { create(:snippet, :repository, :read_only).tap { |snippet| snippet.create_repository } }

      it 'does not get scheduled' do
        expect(subject).to receive(:log_info)
          .with("Snippet #{snippet.full_path} (#{snippet.id}) was skipped: Snippet is read only")
        expect { subject.execute(source_storage_name, destination_storage_name) }
          .to change(SnippetRepositoryStorageMove, :count).by(0)
      end
    end
  end

  describe '.enqueue' do
    it 'defers to the worker' do
      expect(::SnippetScheduleBulkRepositoryShardMovesWorker).to receive(:perform_async).with(source_storage_name, destination_storage_name)

      described_class.enqueue(source_storage_name, destination_storage_name)
    end
  end
end
