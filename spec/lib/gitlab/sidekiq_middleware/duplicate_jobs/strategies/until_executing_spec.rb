# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SidekiqMiddleware::DuplicateJobs::Strategies::UntilExecuting do
  it_behaves_like 'deduplicate job strategy', described_class, 'until executing' do
    describe '#perform' do
      let(:proc) { -> {} }

      it 'deletes the lock before executing' do
        expect(fake_duplicate_job).to receive(:delete!).ordered
        expect { |b| strategy.perform({}, &b) }.to yield_control
      end
    end
  end
end
