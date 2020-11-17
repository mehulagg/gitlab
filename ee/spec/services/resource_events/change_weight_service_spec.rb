# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ResourceEvents::ChangeWeightService do
  let_it_be(:user) { create(:user) }

  let(:issue) { create(:issue, weight: 3) }
  let(:created_at_time) { Time.utc(2019, 1, 1, 12, 30, 48, '123.123'.to_r) }

  subject { described_class.new([issue], user, created_at_time).execute }

  before do
    ResourceWeightEvent.new(issue: issue, user: user).save!
  end

  it 'creates the expected event record' do
    expect { subject }.to change { ResourceWeightEvent.count }.by(1)

    record = ResourceWeightEvent.last
    expect_event_record(record, weight: 3, created_at: created_at_time)
  end

  context 'when weight is nil' do
    let(:issue) { create(:issue, weight: nil) }

    it 'creates an event record' do
      expect { subject }.to change { ResourceWeightEvent.count }.by(1)

      record = ResourceWeightEvent.last
      expect_event_record(record, weight: nil, created_at: created_at_time)
    end
  end

  context 'when there is no existing weight event record' do
    before do
      ResourceWeightEvent.delete_all
      issue.update!(weight: 5, updated_at: 10.seconds.ago)
    end

    it 'creates the expected event records' do
      prev_update_at = issue.previous_changes['updated_at']&.first

      expect { subject }.to change { ResourceWeightEvent.count }.by(2)

      record = ResourceWeightEvent.first
      expect_event_record(record, weight: 3, created_at: prev_update_at)

      record = ResourceWeightEvent.last
      expect_event_record(record, weight: 5, created_at: created_at_time)
    end
  end

  def expect_event_record(record, weight:, created_at:)
    expect(record.issue).to eq(issue)
    expect(record.user).to eq(user)
    expect(record.weight).to eq(weight)
    expect(record.created_at).to be_like_time(created_at)
  end

  describe 'bulk issue weight updates' do
    let(:issues) { create_list(:issue, 3, weight: 1) }

    before do
      issues.each { |issue| issue.update!(weight: 3) }
    end

    it 'bulk insert weight changes' do
      expect do
        described_class.new(issues, user, created_at_time).execute
      end.to change { ResourceWeightEvent.count }.by(6)
    end

    it 'calls first_weight_event? once per resource' do
      service = described_class.new(issues, user, created_at_time)
      allow(service).to receive(:first_weight_event?).exactly(3).times

      service.execute
    end
  end
end
