# frozen_string_literal: true

require 'spec_helper'

describe ScheduleConsolidateCountersWorker, :counter_attribute do
  let(:model) { TestCounterAttribute }

  describe '#perform', :redis do
    let(:worker) { described_class.new }

    subject { worker.perform }

    before do
      stub_const("#{described_class}::COUNTER_ATTRIBUTE_MODELS", [model])
    end

    it 'schedules a worker for each model using CounterAttribute concern' do
      expect(ConsolidateCountersWorker).to receive(:perform_async).with(model.name)

      subject
    end
  end
end
