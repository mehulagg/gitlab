# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::RelationExportService do
  let_it_be(:relation) { 'labels' }
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:label) { create(:group_label, group: group) }
  let_it_be(:export_path) { "#{Dir.tmpdir}/relation_export_service_spec/tree" }
  let_it_be_with_reload(:export) { create(:bulk_import_export, group: group, relation: relation) }

  before do
    group.add_owner(user)

    allow(export).to receive(:export_path).and_return(export_path)
  end

  after :all do
    FileUtils.rm_rf(export_path)
  end

  subject { described_class.new(export) }

  describe '#perform' do
    it 'exports specified relation' do
      subject.execute

      expect(export.reload.upload.export_file).to be_present
    end

    it 'removes temp export files' do
      subject.execute

      expect(Dir.exist?(export_path)).to eq(false)
    end

    context 'when there is existing export present' do
      let(:upload) { create(:bulk_import_export_upload, export: export) }

      before do
        upload.export_file = fixture_file_upload('spec/fixtures/bulk_imports/labels.ndjson.gz')
        upload.save!
      end

      it 'removes existing export before exporting' do
        expect_any_instance_of(BulkImports::ExportUpload) do |upload|
          expect(upload).to receive(:remove_export_file!)
        end

        subject.execute
      end
    end
  end
end
