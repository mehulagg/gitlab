# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::ImportWorker do
  subject { described_class.new }

  describe '#perform' do
    it 'enqueues Stage::ImportGroupsWorker' do
      bulk_import = create(:bulk_import)

      expect(BulkImports::Stage::ImportGroupsWorker).to receive(:perform_async).with(bulk_import.id)

      subject.perform(bulk_import.id)
    end
  end
end
