# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Metric do
  let(:key_path) { 'counts.issues' }
  let(:attributes) { { key_path: key_path, description: 'Issues count' } }
  let(:definition) { Gitlab::Usage::MetricDefinition.new("metric/definition.yml", attributes) }

  describe '#key_path' do
    it 'returns key_path metric definition' do
      expect(described_class.new(definition: definition).key_path).to eq(key_path)
    end
  end

  describe '#instrument' do
    using RSpec::Parameterized::TableSyntax

    context 'with values' do
      where(:key_path, :value, :expected_hash) do
        'uuid'                                     | nil    | { uuid: nil }
        'uuid'                                     | '1111' | { uuid: '1111' }
        'counts.issues'                            | nil    | { counts: { issues: nil } }
        'counts.issues'                            | 100    | { counts: { issues: 100 } }
        'usage_activity_by_stage.verify.ci_builds' | 100    | { usage_activity_by_stage: { verify: { ci_builds: 100 } } }
      end

      with_them do
        let(:definition) { Gitlab::Usage::MetricDefinition.new("metric/definition.yml", attributes.merge(key_path: key_path)) }

        subject { described_class.new(definition: definition).instrument(value) }

        it { is_expected.to eq(expected_hash) }
      end
    end
  end

  context 'with blocks' do
    let!(:issue) { create(:issue) }
    let(:definition) { Gitlab::Usage::MetricDefinition.new("metric/definition.yml", attributes) }

    subject { described_class.new(definition: definition) }

    it 'gets the correct value' do
      expect(subject.instrument { Issue.count }).to eq({ counts: { issues: 1 } })
    end

    it 'gets the fallback value' do
      expect(subject.instrument { raise 1 }).to eq({ counts: { issues: -1 } })
    end

    it 'gets the set fallback value' do
      expect(subject.instrument(fallback: -100) { raise 1 }).to eq({ counts: { issues: -100 } })
    end
  end
end
