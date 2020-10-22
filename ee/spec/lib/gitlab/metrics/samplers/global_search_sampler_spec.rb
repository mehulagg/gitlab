# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Metrics::Samplers::GlobalSearchSampler do
  subject { described_class.new }

  describe '#interval' do
    it 'samples every sixty seconds by default' do
      expect(subject.interval).to eq(60)
    end

    it 'samples at other intervals if requested' do
      expect(described_class.new(11).interval).to eq(11)
    end
  end

  describe '#sample' do
    it 'invokes the Elastic::MetricsUpdateService' do
      expect_next_instance_of(::Elastic::MetricsUpdateService) do |service|
        expect(service).to receive(:execute)
      end

      subject.sample
    end
  end
end
