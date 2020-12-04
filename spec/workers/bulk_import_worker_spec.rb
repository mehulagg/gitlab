#  frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImportWorker do
  let_it_be(:bulk_import) { create(:bulk_import) }

  describe '#perform' do
    context 'when there is entities to be imported' do
      let!(:bulk_import_entity) { create(:bulk_import_entity, bulk_import: bulk_import) }

      it 'enqueues entity processing jobs' do
        expect(BulkImports::ProcessEntityWorker).to receive(:perform_async).with(bulk_import_entity.id)
        expect(BulkImportWorker).to receive(:perform_async).with(bulk_import.id)

        subject.execute

        expect(bulk_import.reload).to be_started
      end
    end

    context 'when there is no entities to be imported' do
      it 'starts the bulk_import and imports its entities' do
        expect(BulkImports::Importers::GroupImporter).not_to receive(:new)
        expect(BulkImportWorker).not_to receive(:perform_async)

        subject.execute

        expect(bulk_import.reload).to be_finished
      end
    end


    it 'executes Group Importer' do
      bulk_import_id = 1

      expect(BulkImports::Importers::GroupsImporter)
        .to receive(:new).with(bulk_import_id).and_return(double(execute: true))

      described_class.new.perform(bulk_import_id)
    end
  end
end
