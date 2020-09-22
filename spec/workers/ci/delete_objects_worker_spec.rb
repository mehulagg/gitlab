# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::DeleteObjectsWorker do
  let(:worker) { described_class.new }

  it { expect(described_class.idempotent?).to be_truthy }

  describe '#perform' do
    it 'executes a service' do
      expect_next_instance_of(Ci::DeleteObjectsService) do |instance|
        expect(instance).to receive(:execute)
        expect(instance).to receive(:remaining_count).once.and_call_original
      end

      worker.perform
    end
  end

  describe '#max_running_jobs' do
    using RSpec::Parameterized::TableSyntax

    before do
      stub_feature_flags(
        ci_delete_objects_low_concurrency: low,
        ci_delete_objects_medium_concurrency: medium,
        ci_delete_objects_high_concurrency: high
      )
    end

    subject(:max_running_jobs) { worker.max_running_jobs }

    where(:low, :medium, :high, :expected) do
      false | false | false | 0
      true  | true  | true  | 2
      true  | false | false | 2
      false | true  | false | 50
      false | true  | true  | 50
      false | false | true  | 200
    end

    with_them do
      it 'sets up concurrency depending on the feature flag' do
        expect(max_running_jobs).to eq(expected)
      end
    end
  end
end
