# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::CreateAllSnapshotsWorker do
  subject(:worker) { described_class.new }

  describe "#perform" do
    let!(:segment1) { create :devops_adoption_segment }
    let!(:segment2) { create :devops_adoption_segment }

    it 'schedules workers for each individual segment' do
      expect(Analytics::DevopsAdoption::CreateSnapshotWorker).to receive(:perform_async).with(segment1.id)
      expect(Analytics::DevopsAdoption::CreateSnapshotWorker).to receive(:perform_async).with(segment2.id)

      worker.perform
    end
  end
end
