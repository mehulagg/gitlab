# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Iterations::CreateIterationsWorker do
  let_it_be(:group) { create(:group) }
  let_it_be(:start_date) { 3.weeks.ago }
  let_it_be(:iteration_cadences) { create_list(:iterations_cadence, 2, group: group, automatic: true, start_date: start_date, duration_in_weeks: 1, iterations_in_advance: 2) }

  subject(:worker) { described_class.new }

  describe '#perform' do
    context 'in batches' do
      let(:mock_service) { double('mock_service', execute: ::ServiceResponse.success) }

      before do
        stub_const("#{described_class}::BATCH_SIZE", 1)
      end

      it "run in batches" do
        expect(Iterations::Cadences::CreateIterationsInAdvanceService).to receive(:new).and_return(mock_service).twice
        expect(Iterations::Cadence).to receive(:for_automated_iterations).and_call_original.once

        worker.perform
      end
    end
  end

  include_examples 'an idempotent worker'
end
