# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Tracking::StandardContext do
  let_it_be(:project) { create(:project) }
  let_it_be(:namespace) { create(:namespace) }

  let(:snowplow_context) { subject.to_context }

  describe '#to_context' do
    context 'with no arguments' do
      it 'creates a Snowplow context with no data' do
        snowplow_context.to_json[:data].each do |_, v|
          expect(v).to be_nil
        end
      end
    end

    context 'with extra data' do
      subject { described_class.new(foo: 'bar') }

      it 'creates a Snowplow context with the given data' do
        expect(snowplow_context.to_json.dig(:data, :foo)).to eq('bar')
      end
    end

    context 'with namespace' do
      subject { described_class.new(namespace: namespace) }

      it 'creates a Snowplow context using the given data' do
        expect(snowplow_context.to_json.dig(:data, :namespace_id)).to eq(namespace.id)
        expect(snowplow_context.to_json.dig(:data, :project_id)).to be_nil
      end
    end

    context 'with project' do
      subject { described_class.new(project: project) }

      it 'creates a Snowplow context using the given data' do
        expect(snowplow_context.to_json.dig(:data, :namespace_id)).to eq(project.namespace.id)
        expect(snowplow_context.to_json.dig(:data, :project_id)).to eq(project.id)
      end
    end

    context 'with project and namespace' do
      subject { described_class.new(namespace: namespace, project: project) }

      it 'creates a Snowplow context using the given data' do
        expect(snowplow_context.to_json.dig(:data, :namespace_id)).to eq(namespace.id)
        expect(snowplow_context.to_json.dig(:data, :project_id)).to eq(project.id)
      end
    end
  end

  describe '#event' do
    it 'delegates to Gitlab::Tracking.event' do
      expect(Gitlab::Tracking).to receive(:event) # rubocop:disable Rspec/ExpectGitlabTracking
        .with('category', 'action', label: 'label', property: 'property', value: 0, context: [],
              standard_context: kind_of(Gitlab::Tracking::StandardContext))

      subject.event('category', 'action', label: 'label', property: 'property', value: 0)
    end
  end
end
