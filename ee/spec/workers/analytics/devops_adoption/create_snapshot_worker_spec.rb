# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::CreateSnapshotWorker do
  subject(:worker) { described_class.new }

  describe "#perform" do
    let!(:segment) { create :devops_adoption_segment }
    let!(:range_end) { 1.day.ago }

    it 'calls for Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService service' do
      expect_next_instance_of(::Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService, segment: segment, range_end: range_end) do |instance|
        expect(instance).to receive(:execute)
      end

      worker.perform(segment.id, range_end)
    end
  end
end
