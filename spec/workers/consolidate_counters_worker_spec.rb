# frozen_string_literal: true

require 'spec_helper'

describe ConsolidateCountersWorker do
  describe '#perform' do
    let(:project_statistics) { create(:project_statistics) }
    let(:model_class_name) { project_statistics.class.name }

    subject { described_class.new.perform(model_class_name) }

    context 'when there are pending events for the same object' do
      before do
        project_statistics.increment_counter(:build_artifacts_size, 10)
        project_statistics.increment_counter(:build_artifacts_size, -3)
      end

      it 'updates the counter and removes the events' do
        subject

        # read directly from the column rather than the getter
        expect(project_statistics.reload.read_attribute('build_artifacts_size')).to eq 7
        expect(project_statistics.counter_events).to be_empty
      end

      it 'performs 1 query to fetch all IDs and 1 query per record to update' do
        expect { subject }.not_to exceed_query_limit(2)
      end
    end

    context 'when there pending events for different objects' do
      let(:project_statistics_2) { create(:project_statistics) }
      let(:project_statistics_3) { create(:project_statistics) }

      before do
        project_statistics.increment_counter(:build_artifacts_size, 10)
        project_statistics.increment_counter(:build_artifacts_size, -3)

        project_statistics_2.increment_counter(:build_artifacts_size, 30)
        project_statistics_2.increment_counter(:build_artifacts_size, 13)
        project_statistics_2.increment_counter(:build_artifacts_size, -1)

        project_statistics_3.increment_counter(:build_artifacts_size, 20)
      end

      it 'updates the counters and removes the events' do
        subject

        # read directly from the column rather than the getter
        expect(project_statistics.reload.read_attribute('build_artifacts_size')).to eq 7
        expect(project_statistics_2.reload.read_attribute('build_artifacts_size')).to eq 42
        expect(project_statistics_3.reload.read_attribute('build_artifacts_size')).to eq 20

        expect(project_statistics.counter_events).to be_empty
      end

      it 'performs 1 query to fetch all IDs and 1 query per record to update' do
        expect { subject }.not_to exceed_query_limit(4)
      end
    end
  end
end
