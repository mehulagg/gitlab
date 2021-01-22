# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe CreateElasticReindexingSubtasks do
  let(:migration) { described_class.new }
  let(:reindexing_tasks) { table(:elastic_reindexing_tasks) }
  let(:reindexing_subtasks) { table(:elastic_reindexing_subtasks) }
  let(:fields_to_migrate) { %w(documents_count documents_count_target index_name_from index_name_to elastic_task) }

  describe "#up" do
    it 'migrates old reindexing tasks' do
      # these tasks should not be migrated
      reindexing_tasks.create!(in_progress: false, state: 10)
      reindexing_tasks.create!(in_progress: false, state: 10, index_name_from: 'index_name')
      reindexing_tasks.create!(in_progress: false, state: 10, index_name_to: 'index_name')
      reindexing_tasks.create!(in_progress: false, state: 10, elastic_task: 'TASK')
      # these tasks should not be migrated

      task1 = reindexing_tasks.create!(in_progress: false, documents_count: 100, state: 10, index_name_from: 'index1', index_name_to: 'index2', elastic_task: 'TASK_ID', documents_count_target: 100)
      task2 = reindexing_tasks.create!(in_progress: false, documents_count: 50, state: 11, index_name_from: 'index3', index_name_to: 'index4', elastic_task: 'TASK_ID2', documents_count_target: 99)

      migrate!

      expect(reindexing_subtasks.count).to eq(2)

      [task1, task2].each do |task|
        subtask = reindexing_subtasks.find_by(elastic_reindexing_task_id: task.id)

        expect(task.attributes.slice(*fields_to_migrate)).to match(subtask.attributes.slice(*fields_to_migrate))
      end
    end
  end
end
