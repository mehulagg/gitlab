# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::SetDefaultIterationCadences, schema: 20201231133921 do
  let(:namespaces) { table(:namespaces) }
  let(:iterations) { table(:sprints) }
  let(:iteration_cadences) { table(:iteration_cadences) }

  describe '#perform' do
    let!(:group_1) { namespaces.create!(name: 'group 1', path: 'group-1') }
    let!(:group_2) { namespaces.create!(name: 'group 2', path: 'group-2') }
    let!(:group_3) { namespaces.create!(name: 'group 3', path: 'group-3') }

    let!(:iteration_1) { iterations.create!(group_id: group_1.id, iid: 1, title: 'Iteration 1', start_date: 10.days.ago, due_date: 8.days.ago) }
    let!(:iteration_2) { iterations.create!(group_id: group_3.id, iid: 1, title: 'Iteration 2', start_date: 10.days.ago, due_date: 8.days.ago) }
    let!(:iteration_3) { iterations.create!(group_id: group_3.id, iid: 1, title: 'Iteration 3', start_date: 5.days.ago, due_date: 2.days.ago) }

    before do
      described_class.new.perform([group_1.id, group_2.id, group_3.id])
    end

    it 'creates iteration_cadence records for the requested groups' do
      expect(iteration_cadences.count).to eq(2)
    end

    it 'assigns the iteration cadences to the iterations correctly' do
      iteration_cadence = iteration_cadences.find_by(group_id: group_1.id)
      iteration_records = iterations.where(iteration_cadence_id: iteration_cadence.id)

      expect(iteration_cadence.start_date).to eq(iteration_1.start_date)
      expect(iteration_cadence.last_run_date).to eq(iteration_1.start_date)
      expect(iteration_records.size).to eq(1)
      expect(iteration_records.first.id).to eq(iteration_1.id)

      iteration_cadence = iteration_cadences.find_by(group_id: group_3.id)
      iteration_records = iterations.where(iteration_cadence_id: iteration_cadence.id)

      expect(iteration_cadence.start_date).to eq(iteration_3.start_date)
      expect(iteration_cadence.last_run_date).to eq(iteration_3.start_date)
      expect(iteration_records.size).to eq(2)
      expect(iteration_records.first.id).to eq(iteration_2.id)
      expect(iteration_records.second.id).to eq(iteration_3.id)
    end
  end
end
