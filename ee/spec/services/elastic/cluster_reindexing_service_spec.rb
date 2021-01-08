# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::ClusterReindexingService, :elastic do
  subject { described_class.new }

  context 'state: initial' do
    let(:task) { create(:elastic_reindexing_task, state: :initial) }

    it 'aborts if the main index does not use aliases' do
      allow(Gitlab::Elastic::Helper.default).to receive(:alias_exists?).and_return(false)

      expect { subject.execute }.to change { task.reload.state }.from('initial').to('failure')
      expect(task.reload.error_message).to match(/use aliases/)
    end

    it 'aborts if there are pending ES migrations' do
      allow(Elastic::DataMigrationService).to receive(:pending_migrations?).and_return(true)

      expect { subject.execute }.to change { task.reload.state }.from('initial').to('failure')
      expect(task.reload.error_message).to match(/unapplied advanced search migrations/)
    end

    it 'errors when there is not enough space' do
      allow(Gitlab::Elastic::Helper.default).to receive(:index_size_bytes).and_return(100.megabytes)
      allow(Gitlab::Elastic::Helper.default).to receive(:cluster_free_size_bytes).and_return(30.megabytes)

      expect { subject.execute }.to change { task.reload.state }.from('initial').to('failure')
      expect(task.reload.error_message).to match(/storage available/)
    end

    it 'pauses elasticsearch indexing' do
      expect(Gitlab::CurrentSettings.elasticsearch_pause_indexing).to eq(false)

      expect { subject.execute }.to change { task.reload.state }.from('initial').to('indexing_paused')

      expect(Gitlab::CurrentSettings.elasticsearch_pause_indexing).to eq(true)
    end
  end

  context 'state: indexing_paused' do
    it 'triggers reindexing' do
      task = create(:elastic_reindexing_task, state: :indexing_paused)

      allow(Gitlab::Elastic::Helper.default).to receive(:create_empty_index).and_return('new_index_name' => 'new_index')
      allow(Gitlab::Elastic::Helper.default).to receive(:create_standalone_indices).and_return('new_issues_name' => 'new_issues')
      allow(Gitlab::Elastic::Helper.default).to receive(:reindex).with(from: anything, to: 'new_index_name').and_return('task_id_1')
      allow(Gitlab::Elastic::Helper.default).to receive(:reindex).with(from: anything, to: 'new_issues_name').and_return('task_id_2')

      expect { subject.execute }.to change { task.reload.state }.from('indexing_paused').to('reindexing')

      subtasks = task.subtasks
      expect(subtasks.count).to eq(2)

      expect(subtasks.first.index_name_to).to eq('new_index_name')
      expect(subtasks.first.elastic_task).to eq('task_id_1')
      expect(subtasks.last.index_name_to).to eq('new_issues_name')
      expect(subtasks.last.elastic_task).to eq('task_id_2')
    end
  end

  context 'state: reindexing' do
    let(:task) { create(:elastic_reindexing_task, state: :reindexing) }
    let(:subtask) { create(:elastic_reindexing_subtask, elastic_reindexing_task: task, documents_count: 10)}
    let(:expected_default_settings) do
      {
        refresh_interval: nil,
        number_of_replicas: Gitlab::CurrentSettings.elasticsearch_replicas,
        translog: { durability: 'request' }
      }
    end

    before do
      allow(Gitlab::Elastic::Helper.default).to receive(:task_status).and_return({ 'completed' => true })
      allow(Gitlab::Elastic::Helper.default).to receive(:refresh_index).and_return(true)
    end

    context 'errors are raised' do
      before do
        allow(Gitlab::Elastic::Helper.default).to receive(:documents_count).with(index_name: subtask.index_name_to).and_return(subtask.reload.documents_count * 2)
      end

      it 'errors if documents count is different' do
        expect { subject.execute }.to change { task.reload.state }.from('reindexing').to('failure')
        expect(task.reload.error_message).to match(/count is different/)
      end

      it 'errors if reindexing is failed' do
        allow(Gitlab::Elastic::Helper.default).to receive(:task_status).and_return({ 'completed' => true, 'error' => { 'type' => 'search_phase_execution_exception' } })

        expect { subject.execute }.to change { task.reload.state }.from('reindexing').to('failure')
        expect(task.reload.error_message).to match(/has failed with/)
      end

      it 'errors if task is not found' do
        allow(Gitlab::Elastic::Helper.default).to receive(:task_status).and_raise(Elasticsearch::Transport::Transport::Errors::NotFound)

        expect { subject.execute }.to change { task.reload.state }.from('reindexing').to('failure')
        expect(task.reload.error_message).to match(/couldn't load task status/i)
      end
    end

    context 'task finishes correctly' do
      before do
        allow(Gitlab::Elastic::Helper.default).to receive(:documents_count).with(index_name: subtask.index_name_to).and_return(subtask.reload.documents_count)
      end

      it 'launches all state steps' do
        expect(Gitlab::Elastic::Helper.default).to receive(:update_settings).with(index_name: subtask.index_name_to, settings: expected_default_settings)
        expect(Gitlab::Elastic::Helper.default).to receive(:switch_alias).with(to: subtask.index_name_to, from: subtask.index_name_from, alias_name: subtask.alias_name)
        expect(Gitlab::CurrentSettings).to receive(:update!).with(elasticsearch_pause_indexing: false)

        expect { subject.execute }.to change { task.reload.state }.from('reindexing').to('success')
        expect(task.reload.delete_original_index_at).to be_within(1.minute).of(described_class::DELETE_ORIGINAL_INDEX_AFTER.from_now)
      end
    end
  end
end
