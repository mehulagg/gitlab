#  frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImportWorker do
  let!(:bulk_import) { create(:bulk_import, :started) }
  let!(:entity) { create(:bulk_import_entity, bulk_import: bulk_import) }

  subject { described_class.new }

  describe '#perform' do
    it 'executes Group Importer' do
      expect_next_instance_of(BulkImports::Importers::GroupsImporter) do |importer|
        expect(importer).to receive(:execute)
      end

      subject.perform(bulk_import.id)
    end
  end
end
