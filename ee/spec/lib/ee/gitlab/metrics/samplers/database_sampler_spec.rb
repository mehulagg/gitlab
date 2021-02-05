# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Metrics::Samplers::DatabaseSampler do
  subject { described_class.new }

  describe '#sample' do
    before do
      described_class::METRIC_DESCRIPTIONS.each_key do |metric|
        allow(subject.metrics[metric]).to receive(:set)
      end
    end

    context 'for Geo::TrackingBase', :geo do
      let(:labels) { a_hash_including(class: 'Geo::TrackingBase', host: anything, port: anything) }

      context 'when Geo is enabled' do
        it 'samples connection pool statistics' do
          expect(subject.metrics[:size]).to receive(:set).with(labels, a_value >= 1)
          expect(subject.metrics[:connections]).to receive(:set).with(labels, a_value >= 0)
          expect(subject.metrics[:busy]).to receive(:set).with(labels, a_value >= 0)
          expect(subject.metrics[:dead]).to receive(:set).with(labels, a_value >= 0)
          expect(subject.metrics[:waiting]).to receive(:set).with(labels, a_value >= 0)

          subject.sample
        end
      end

      context 'when Geo is not enabled' do
        before do
          allow(Geo::TrackingBase).to receive(:connected?).and_return(false)
        end

        it 'records no samples' do
          expect(subject.metrics[:size]).not_to receive(:set).with(labels, anything)

          subject.sample
        end

        it 'still records samples for other connections' do
          expect(subject.metrics[:size]).to receive(:set)

          subject.sample
        end
      end
    end
  end
end
