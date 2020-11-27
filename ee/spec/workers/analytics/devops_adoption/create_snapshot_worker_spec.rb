# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::CreateSnapshotWorker do
  subject(:worker) { described_class.new }

  describe "#perform" do
    let!(:segment) { create :devops_adoption_segment }

    it 'calls for Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService service' do
      expect_next_instance_of(::Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService, segment: segment) do |instance|
        expect(instance).to receive(:execute)
      end

      worker.perform(segment.id)
    end
  end
end
