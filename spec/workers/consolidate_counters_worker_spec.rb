# frozen_string_literal: true

require 'spec_helper'

describe ConsolidateCountersWorker, :counter_attribute do
  let(:model) { TestCounterAttribute }

  describe '#perform', :redis do
    let(:processing_lock_key) { "counter-attributes:#{model}" }
    let(:worker) { described_class.new }

    subject { worker.perform(model.name) }

    it 'obtains an exclusive lease during processing' do
      expect(worker)
        .to receive(:in_lock)
        .with(processing_lock_key, ttl: described_class::LOCK_TTL)
        .and_call_original

      subject
    end

    it 'consolidates counter attributes' do
      expect(model)
        .to receive(:slow_consolidate_counter_attributes!)
        .and_call_original

      subject
    end

    context 'when model class does not exist' do
      subject { worker.perform('non-existend-model') }

      it 'does nothing' do
        expect(worker).not_to receive(:in_lock)
      end
    end
  end
end
