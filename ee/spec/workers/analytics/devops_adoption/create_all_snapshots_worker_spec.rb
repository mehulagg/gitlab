# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::CreateAllSnapshotsWorker do
  subject(:worker) { described_class.new }

  describe "#perform" do
    let!(:segment1) { create :devops_adoption_segment }
    let!(:segment2) { create :devops_adoption_segment }

    it 'schedules workers for each individual segment' do
      freeze_time do
        expect(Analytics::DevopsAdoption::CreateSnapshotWorker).to receive(:perform_in).with(0, segment1.id, Time.zone.now)
        expect(Analytics::DevopsAdoption::CreateSnapshotWorker).to receive(:perform_in).with(5, segment2.id, Time.zone.now)

        worker.perform
      end
    end
  end
end
