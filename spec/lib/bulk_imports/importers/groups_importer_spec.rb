# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Importers::GroupsImporter do
  let(:bulk_import) { create(:bulk_import) }
  let(:bulk_import_entity) { create(:bulk_import_entity, bulk_import: bulk_import) }
  let(:job_waiter) { Gitlab::JobWaiter.new(2, 'bulk_imports:importers:groups_importer') }

  subject { described_class.new(bulk_import.id) }

  describe '#execute' do
    before do
      allow(Gitlab::JobWaiter).to receive(:new).and_return(job_waiter)
    end

    context 'when bulk import is present' do
      it 'enqueues ImportGroupWorker for each import entity' do
        expect(BulkImports::ImportGroupWorker).to receive(:perform_async).with(bulk_import.id, bulk_import_entity.id, job_waiter.key)

        subject.execute
      end
    end

    context 'when bulk import is not found' do
      it 'does not enqueue ImportGroupWorker' do
        expect(BulkImports::ImportGroupWorker).not_to receive(:perform_async)

        subject.execute
      end
    end
  end
end
