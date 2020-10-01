# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peek::Views::ActiveRecord, :request_store do
  context 'when a class defines thresholds' do
    let(:threshold_view) do
      Class.new(described_class) do
        def self.thresholds
          {
            calls: 1,
            cached_calls: 1,
            duration: 10,
            individual_call: 5
          }
        end

        def key
          'threshold-view'
        end
      end.new
    end

    context 'when the results exceed the cached calls threshold' do
      before do
        allow(threshold_view)
          .to receive(:detail_store).and_return([{ duration: 0.001, cached: 'cached' }, { duration: 0.001, cached: 'cached' }])
      end

      it 'adds a warning to the results key' do
        expect(threshold_view.results).to include(warnings: [a_string_matching('threshold-view cached calls')])
      end
    end
  end
end
