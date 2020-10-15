# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Stage::FinishImportWorker do
  subject { described_class.new }

  describe '#perform' do
    it 'marks bulk import as finished' do
      bulk_import = create(:bulk_import, :started)

      subject.perform(bulk_import.id)

      expect(bulk_import.reload.human_status_name).to eq('finished')
    end
  end
end
