#  frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImportWorker do
  let!(:bulk_import) { create(:bulk_import, :started) }
  let!(:entity) { create(:bulk_import_entity, bulk_import: bulk_import) }
  let(:importer) { double(execute: nil) }
  let(:creator) { double(execute: nil) }

  subject { described_class.new }

  describe '#perform' do
    before do
      allow(BulkImports::Importers::GroupImporter).to receive(:new).and_return(importer)
      allow(BulkImports::SubgroupEntitiesCreator).to receive(:new).and_return(creator)
    end

    it 'executes Group Importer' do
      expect(importer).to receive(:execute)

      subject.perform(bulk_import.id)
    end

    it 'executes Subgroup Entities Creator' do
      expect(creator).to receive(:execute)

      subject.perform(bulk_import.id)
    end

    it 'updates bulk import and entity state' do
      subject.perform(bulk_import.id)

      expect(bulk_import.reload.human_status_name).to eq('finished')
      expect(entity.reload.human_status_name).to eq('finished')
    end

    context 'when bulk import could not be found' do
      it 'does nothing' do
        expect(bulk_import).not_to receive(:top_level_groups)
        expect(bulk_import).not_to receive(:finish!)

        subject.perform(non_existing_record_id)
      end
    end

    context 'when there are entities with parent_id' do
      let!(:child_entity) { create(:bulk_import_entity, bulk_import: bulk_import, parent: entity) }
      let!(:descendant_entity) { create(:bulk_import_entity, bulk_import: bulk_import, parent: child_entity) }

      it 'executes Group Importer for descendant entity' do
        expect(BulkImports::Importers::GroupImporter).to receive(:new).with(entity.id)
        expect(BulkImports::Importers::GroupImporter).to receive(:new).with(child_entity.id)
        expect(BulkImports::Importers::GroupImporter).to receive(:new).with(descendant_entity.id)

        subject.perform(bulk_import.id)
      end
    end
  end
end
