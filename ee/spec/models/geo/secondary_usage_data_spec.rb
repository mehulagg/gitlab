# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::SecondaryUsageData, :geo, type: :model do
  subject { create(:geo_secondary_usage_data) }

  let(:prometheus_client) { Gitlab::PrometheusClient.new('http://localhost:9090') }

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'cannot have undefined fields in the payload' do
    subject.payload['nope_does_not_exist'] = 'whatever'
    expect(subject).not_to be_valid
  end

  shared_examples_for 'a payload count field' do |field|
    it "defines #{field} as a method" do
      expect(subject.methods).to include(field.to_sym)
    end

    it "does not allow #{field} to be a string" do
      subject.payload[field] = 'a string'
      expect(subject).not_to be_valid
    end

    it "allows #{field} to be nil" do
      subject.payload[field] = nil
      expect(subject).to be_valid
    end

    it "may not define #{field} in the payload json" do
      subject.payload.except!(field)
      expect(subject).to be_valid
    end
  end

  Geo::SecondaryUsageData::PAYLOAD_COUNT_FIELDS.each do |field|
    context "##{field}" do
      it_behaves_like 'a payload count field', field
    end
  end

  describe '#update_metrics!' do
    let(:new_data) { double(Geo::SecondaryUsageData) }

    before do
      allow_next_instance_of(described_class) do |instance|
        allow(instance).to receive(:with_prometheus_client).and_yield(prometheus_client)
      end

      allow(prometheus_client).to receive(:query).and_return([])
    end

    context 'metric git_fetch_event_count_weekly' do
      it 'gets metrics from prometheus' do
        expected_result = 48
        allow(prometheus_client).to receive(:query).with(Geo::SecondaryUsageData::GIT_FETCH_EVENT_COUNT_WEEKLY_QUERY).and_return([{ "value" => [1614029769.82, expected_result.to_s] }])

        expect do
          described_class.update_metrics!
        end.to change { described_class.count }.by(1)

        expect(described_class.last).to be_valid
        expect(described_class.last.git_fetch_event_count_weekly).to eq(expected_result)
      end

      it 'returns nil if metric is unavailable' do
        allow(prometheus_client).to receive(:query).with(Geo::SecondaryUsageData::GIT_FETCH_EVENT_COUNT_WEEKLY_QUERY).and_return([])

        expect do
          described_class.update_metrics!
        end.to change { described_class.count }.by(1)

        expect(described_class.last).to be_valid
        expect(described_class.last.git_fetch_event_count_weekly).to be_nil
      end

      it 'returns nil if it cannot reach prometheus' do
        expect_next_instance_of(described_class) do |instance|
          expect(instance).to receive(:with_prometheus_client).and_return(nil)
        end

        expect do
          described_class.update_metrics!
        end.to change { described_class.count }.by(1)

        expect(described_class.last).to be_valid
        expect(described_class.last.git_fetch_event_count_weekly).to be_nil
      end
    end

    context 'metric git_push_event_count_weekly' do
      it 'gets metrics from prometheus' do
        expected_result = 48
        allow(prometheus_client).to receive(:query).with(Geo::SecondaryUsageData::GIT_PUSH_EVENT_COUNT_WEEKLY_QUERY).and_return([{ "value" => [1614029769.82, expected_result.to_s] }])

        expect do
          described_class.update_metrics!
        end.to change { described_class.count }.by(1)

        expect(described_class.last).to be_valid
        expect(described_class.last.git_push_event_count_weekly).to eq(expected_result)
      end

      it 'returns nil if metric is unavailable' do
        allow(prometheus_client).to receive(:query).with(Geo::SecondaryUsageData::GIT_PUSH_EVENT_COUNT_WEEKLY_QUERY).and_return([])

        expect do
          described_class.update_metrics!
        end.to change { described_class.count }.by(1)

        expect(described_class.last).to be_valid
        expect(described_class.last.git_push_event_count_weekly).to be_nil
      end

      it 'returns nil if it cannot reach prometheus' do
        expect_next_instance_of(described_class) do |instance|
          expect(instance).to receive(:with_prometheus_client).and_return(nil)
        end

        expect do
          described_class.update_metrics!
        end.to change { described_class.count }.by(1)

        expect(described_class.last).to be_valid
        expect(described_class.last.git_push_event_count_weekly).to be_nil
      end
    end
  end
end
