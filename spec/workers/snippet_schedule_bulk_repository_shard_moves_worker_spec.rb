# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SnippetScheduleBulkRepositoryShardMovesWorker do
  let_it_be(:snippet) { create(:snippet, :repository).tap { |snippet| snippet.create_repository } }

  let(:source_storage_name) { 'default' }
  let(:destination_storage_name) { 'test_second_storage' }

  describe "#perform" do
    before do
      stub_storage_settings(destination_storage_name => { 'path' => 'tmp/tests/extra_storage' })

      allow(SnippetUpdateRepositoryStorageWorker).to receive(:perform_async)
    end

    include_examples 'an idempotent worker' do
      let(:job_args) { [source_storage_name, destination_storage_name] }

      it 'schedules snippet repository storage moves' do
        expect { subject }.to change(SnippetRepositoryStorageMove, :count).by(1)

        storage_move = snippet.repository_storage_moves.last!

        expect(storage_move).to have_attributes(
          source_storage_name: source_storage_name,
          destination_storage_name: destination_storage_name,
          state_name: :scheduled
        )
      end
    end
  end
end
