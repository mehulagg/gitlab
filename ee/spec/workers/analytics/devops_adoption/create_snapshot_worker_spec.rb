# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::CreateSnapshotWorker do
  subject(:worker) { described_class.new }

  describe "#perform" do
    let!(:enabled_namespace) { create :devops_adoption_enabled_namespace }

    let!(:pending_snapshot) do
      create(:devops_adoption_snapshot,
             namespace: enabled_namespace.namespace,
             end_time: DateTime.parse('2020-10-01').end_of_month,
             recorded_at: DateTime.parse('2020-10-20')).reload
    end

    let!(:finalized_snapshot) do
      create(:devops_adoption_snapshot,
             namespace: enabled_namespace.namespace,
             end_time: DateTime.parse('2020-09-01').end_of_month,
             recorded_at: DateTime.parse('2020-10-20')).reload
    end

    let(:service_mock) { instance_double('Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService', execute: true) }

    it 'updates metrics for all not finalized snapshots and current month' do
      freeze_time do
        allow_next_instance_of(Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService, enabled_namespace: enabled_namespace, range_end: pending_snapshot.end_time) do |instance|
          expect(instance).to receive(:execute)
        end
        allow_next_instance_of(Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService, enabled_namespace: enabled_namespace, range_end: finalized_snapshot.end_time) do |instance|
          expect(instance).not_to receive(:execute)
        end
        allow_next_instance_of(Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService, enabled_namespace: enabled_namespace, range_end: Time.zone.now.end_of_month) do |instance|
          expect(instance).to receive(:execute)
        end

        worker.perform(enabled_namespace.id)
      end
    end

    context 'when metric for current month already exists' do
      it 'calls for current month calculation only once' do
        travel_to(pending_snapshot.recorded_at + 1.day) do
          allow_next_instance_of(Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService, enabled_namespace: enabled_namespace, range_end: pending_snapshot.end_time) do |instance|
            expect(instance).to receive(:execute).once
          end
          allow_next_instance_of(Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService, enabled_namespace: enabled_namespace, range_end: finalized_snapshot.end_time) do |instance|
            expect(instance).not_to receive(:execute)
          end

          worker.perform(enabled_namespace.id)
        end
      end
    end

    context 'when today is first day of the month' do
      it 'doesnt update metrics for current month' do
        travel_to((pending_snapshot.recorded_at + 1.month).beginning_of_month) do
          allow_next_instance_of(Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService, enabled_namespace: enabled_namespace, range_end: pending_snapshot.end_time) do |instance|
            expect(instance).to receive(:execute)
          end
          allow_next_instance_of(Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService, enabled_namespace: enabled_namespace, range_end: finalized_snapshot.end_time) do |instance|
            expect(instance).not_to receive(:execute)
          end
          allow_next_instance_of(Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService, enabled_namespace: enabled_namespace, range_end: Time.zone.now.end_of_month) do |instance|
            expect(instance).not_to receive(:execute)
          end

          worker.perform(enabled_namespace.id)
        end
      end
    end
  end
end
