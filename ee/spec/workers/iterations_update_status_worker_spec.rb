# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IterationsUpdateStatusWorker do
  subject(:worker) { described_class.new }

  describe '#perform' do
    context 'when iterations are in `upcoming` state' do
      let_it_be(:closed_iteration1) { create(:iteration, :skip_future_date_validation, start_date: 20.days.ago, due_date: 11.days.ago) }
      let_it_be(:closed_iteration2) { create(:iteration, :skip_future_date_validation, start_date: 10.days.ago, due_date: 3.days.ago) }
      let_it_be(:started_iteration) { create(:iteration, :skip_future_date_validation, start_date: Date.current, due_date: 10.days.from_now) }
      let_it_be(:upcoming_iteration) { create(:iteration, start_date: 11.days.from_now, due_date: 13.days.from_now) }

      it 'updates the status of iterations that require it', :aggregate_failures do
        expect(closed_iteration1.state).to eq('closed')
        expect(closed_iteration2.state).to eq('closed')
        expect(started_iteration.state).to eq('started')
        expect(upcoming_iteration.state).to eq('upcoming')

        closed_iteration2.update!(state: 'upcoming')
        worker.perform

        expect(closed_iteration1.reload.state).to eq('closed')
        expect(closed_iteration2.reload.state).to eq('closed')
        expect(started_iteration.reload.state).to eq('started')
        expect(upcoming_iteration.reload.state).to eq('upcoming')
      end
    end

    context 'when iterations are in `started` state' do
      let_it_be(:iteration1) { create(:iteration, :skip_future_date_validation, start_date: 10.days.ago, due_date: 2.days.ago) }
      let_it_be(:iteration2) { create(:iteration, :skip_future_date_validation, start_date: 1.day.ago, due_date: Date.today, state_enum: ::Iteration::STATE_ENUM_MAP[:started]) }

      it 'updates from started to closed when due date is past, does not touch others', :aggregate_failures do
        expect(iteration1.state).to eq('closed')
        expect(iteration2.state).to eq('started')

        iteration1.update!(state: 'started')
        worker.perform

        expect(iteration1.reload.state).to eq('closed')
        expect(iteration2.reload.state).to eq('started')
      end
    end
  end
end
