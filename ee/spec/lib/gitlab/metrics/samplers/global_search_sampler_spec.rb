# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Metrics::Samplers::GlobalSearchSampler do
  subject { described_class.new }

  it_behaves_like 'metrics sampler', 'GLOBAL_SEARCH_SAMPLER'

  describe '#sample' do
    it 'invokes the Elastic::MetricsUpdateService' do
      expect_next_instance_of(::Elastic::MetricsUpdateService) do |service|
        expect(service).to receive(:execute)
      end

      subject.sample
    end
  end
end
