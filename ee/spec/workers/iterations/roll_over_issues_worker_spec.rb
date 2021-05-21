# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Iterations::RollOverIssuesWorker do
  let_it_be(:group) { create(:group) }
  let_it_be(:cadence) { create(:iterations_cadence, group: group, roll_over: true, automatic: true) }
  let_it_be(:closed_iteration1) { create(:closed_iteration, :skip_future_date_validation, iterations_cadence: cadence, group: group, start_date: 20.days.ago, due_date: 11.days.ago) }
  let_it_be(:started_iteration2) { create(:started_iteration, :skip_future_date_validation, iterations_cadence: cadence, group: group, start_date: 10.days.ago, due_date: 5.days.ago) }
  let_it_be(:started_iteration) { create(:started_iteration, :skip_future_date_validation, iterations_cadence: cadence, group: group, start_date: 2.days.ago, due_date: 5.days.from_now) }
  let_it_be(:upcoming_iteration) { create(:upcoming_iteration, start_date: 11.days.from_now, iterations_cadence: cadence, group: group, due_date: 13.days.from_now) }

  let(:mock_service) { double('mock service', execute: ::ServiceResponse.success) }

  subject(:worker) { described_class.new }

  describe '#perform' do
    context 'when iteration cadence is not automatic' do
      before do
        cadence.update!(automatic: false)
      end

      it 'exits early' do
        expect(Iterations::RollOverIssuesService).not_to receive(:new)

        worker.perform(group.iterations)
      end
    end

    context 'when roll-over option on iteration cadence is not enabled' do
      before do
        cadence.update!(roll_over: false)
      end

      it 'exits early' do
        expect(Iterations::RollOverIssuesService).not_to receive(:new)

        worker.perform(group.iterations)
      end
    end

    context 'when roll-over option on iteration cadence is enabled' do
      it 'filters out any iterations that are not closed' do
        expect(Iterations::RollOverIssuesService).to receive(:new).and_return(mock_service).twice
        expect(Iterations::Cadences::CreateIterationsInAdvanceService).to receive(:new).and_return(mock_service).twice
        expect(Iteration).to receive(:closed).and_call_original.once

        worker.perform(group.iterations)
      end

      context 'with batches' do
        before do
          stub_const("#{described_class}::BATCH_SIZE", 1)
        end

        it "run in batches" do
          expect(Iterations::RollOverIssuesService).to receive(:new).and_return(mock_service).twice
          expect(Iteration).to receive(:closed).and_call_original.once

          worker.perform(group.iterations)
        end
      end
    end
  end

  include_examples 'an idempotent worker' do
    let(:job_args) { [group.iterations] }
  end
end
