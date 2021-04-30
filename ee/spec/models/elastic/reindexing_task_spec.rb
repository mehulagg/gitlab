# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::ReindexingTask, type: :model do
  let(:helper) { Gitlab::Elastic::Helper.new }

  before do
    allow(Gitlab::Elastic::Helper).to receive(:default).and_return(helper)
  end

  describe 'relations' do
    it { is_expected.to have_many(:subtasks) }
  end

  it 'only allows one running task at a time' do
    expect { create(:elastic_reindexing_task, state: :success) }.not_to raise_error
    expect { create(:elastic_reindexing_task) }.not_to raise_error
    expect { create(:elastic_reindexing_task) }.to raise_error(/violates unique constraint/)
  end

  it 'sets in_progress flag' do
    task = create(:elastic_reindexing_task, state: :success)
    expect(task.in_progress).to eq(false)

    task.update!(state: :reindexing)
    expect(task.in_progress).to eq(true)
  end

  it 'sets default values for max_slices_running and slice_multiplier' do
    # supports field not being set and field being set to nil
    task = described_class.create!(max_slices_running: nil)

    expect(task).to be_valid
    expect(task.max_slices_running).to eq(60)
    expect(task.slice_multiplier).to eq(2)
  end

  describe '.drop_old_indices!' do
    let(:task_1) { create(:elastic_reindexing_task, :with_subtask, state: :reindexing, delete_original_index_at: 1.day.ago) }
    let(:task_2) { create(:elastic_reindexing_task, :with_subtask, state: :success, delete_original_index_at: nil) }
    let(:task_3) { create(:elastic_reindexing_task, :with_subtask, state: :success, delete_original_index_at: 1.day.ago) }
    let(:task_4) { create(:elastic_reindexing_task, :with_subtask, state: :success, delete_original_index_at: 5.days.ago) }
    let(:task_5) { create(:elastic_reindexing_task, :with_subtask, state: :success, delete_original_index_at: 14.days.from_now) }
    let(:tasks_for_deletion) { [task_3, task_4] }
    let(:other_tasks) { [task_1, task_2, task_5] }

    it 'deletes the correct indices' do
      other_tasks.each do |task|
        expect(helper).not_to receive(:delete_index).with(index_name: task.subtasks.first.index_name_from)
      end

      tasks_for_deletion.each do |task|
        expect(helper).to receive(:delete_index).with(index_name: task.subtasks.first.index_name_from).and_return(true)
      end

      described_class.drop_old_indices!

      tasks_for_deletion.each do |task|
        expect(task.reload.state).to eq('original_index_deleted')
      end
    end
  end
end
