# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::Pipelines::ExpireArtifactsWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    it 'executes a service' do
      expect_next_instance_of(::Ci::Pipelines::DestroyExpiredArtifactsService) do |instance|
        expect(instance).to receive(:execute)
      end

      worker.perform
    end
  end
end
