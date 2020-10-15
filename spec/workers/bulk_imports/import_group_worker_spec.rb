# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::ImportGroupWorker do
  let(:bulk_import) { create(:bulk_import) }
  let(:bulk_import_entity) { create(:bulk_import_entity, bulk_import: bulk_import) }
  let(:key) { 'bulk_imports:import_group_worker' }
  let(:job_waiter) { Gitlab::JobWaiter.new(2, key) }

  subject { described_class.new }

  describe '#perform' do
    before do
      subject.jid = key
    end

    context 'when bulk import is found' do
      it 'updates entity status during import' do
        expect(Gitlab::JobWaiter).to receive(:notify).with(job_waiter.key, subject.jid)
        expect_next_instance_of(BulkImports::Importers::GroupImporter) do |importer|
          expect(importer).to receive(:execute)
        end

        subject.perform(bulk_import.id, bulk_import_entity.id, job_waiter.key)

        expect(bulk_import_entity.reload.human_status_name).to eq('finished')
      end
    end

    context 'when bulk import is not found' do
      before do
        allow(BulkImport).to receive(:find).with(bulk_import.id).and_return(nil)
      end

      it 'notifies job waiter' do
        expect(Gitlab::JobWaiter).to receive(:notify).with(job_waiter.key, subject.jid)

        subject.perform(bulk_import.id, bulk_import_entity.id, job_waiter.key)
      end

      it 'does not update entity import status' do
        expect(bulk_import_entity).not_to receive(:start!)

        subject.perform(bulk_import.id, bulk_import_entity.id, job_waiter.key)
      end
    end
  end
end
