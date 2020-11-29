# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::ClusterReindexingService, :elastic do
  subject { described_class.new }

  context 'state: initial' do
    let(:task) { create(:elastic_reindexing_task, state: :initial) }

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

      allow(Gitlab::Elastic::Helper.default).to receive(:create_empty_index).and_return('new_index_name')
      allow(Gitlab::Elastic::Helper.default).to receive(:reindex).and_return('task_id')

      expect { subject.execute }.to change { task.reload.state }.from('indexing_paused').to('reindexing')

      task = task.reload
      expect(task.index_name_to).to eq('new_index_name')
      expect(task.elastic_task).to eq('task_id')
    end
  end

  context 'state: reindexing' do
    let(:task) { create(:elastic_reindexing_task, state: :reindexing, documents_count: 10) }
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
        allow(Gitlab::Elastic::Helper.default).to receive(:documents_count).with(index_name: task.index_name_to).and_return(task.reload.documents_count * 2)
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
        allow(Gitlab::Elastic::Helper.default).to receive(:documents_count).with(index_name: task.index_name_to).and_return(task.reload.documents_count)
      end

      it 'launches all state steps' do
        expect(Gitlab::Elastic::Helper.default).to receive(:update_settings).with(index_name: task.index_name_to, settings: expected_default_settings)
        expect(Gitlab::Elastic::Helper.default).to receive(:switch_alias).with(to: task.index_name_to)
        expect(Gitlab::CurrentSettings).to receive(:update!).with(elasticsearch_pause_indexing: false)

        expect { subject.execute }.to change { task.reload.state }.from('reindexing').to('success')
        expect(task.reload.delete_original_index_at).to be_within(1.minute).of(described_class::DELETE_ORIGINAL_INDEX_AFTER.from_now)
      end
    end
  end
end
