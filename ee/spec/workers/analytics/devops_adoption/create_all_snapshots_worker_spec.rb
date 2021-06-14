# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::CreateAllSnapshotsWorker do
  subject(:worker) { described_class.new }

  describe "#perform" do
    let!(:enabled_namespace1) { create :devops_adoption_enabled_namespace }
    let!(:enabled_namespace2) { create :devops_adoption_enabled_namespace }

    it 'schedules workers for each individual enabled_namespace' do
      freeze_time do
        expect(Analytics::DevopsAdoption::CreateSnapshotWorker).to receive(:perform_in).with(0, enabled_namespace1.id)
        expect(Analytics::DevopsAdoption::CreateSnapshotWorker).to receive(:perform_in).with(5, enabled_namespace2.id)

        worker.perform
      end
    end
  end
end
