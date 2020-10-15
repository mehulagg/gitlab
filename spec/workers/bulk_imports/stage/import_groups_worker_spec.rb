# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Stage::ImportGroupsWorker do
  let(:bulk_import) { create(:bulk_import) }
  let(:job_waiter) { Gitlab::JobWaiter.new(2, 'bulk_imports:import_groups_worker') }

  subject { described_class.new }

  describe '#perform' do
    before do
      expect_next_instance_of(BulkImports::Importers::GroupsImporter) do |importer|
        expect(importer).to receive(:execute).and_return(job_waiter)
      end
    end

    it 'executes Groups Importer' do
      subject.perform(bulk_import.id)
    end

    it 'advances to the next import stage' do
      expect(BulkImports::AdvanceStageWorker)
        .to receive(:perform_async)
        .with(bulk_import.id, { job_waiter.key => job_waiter.jobs_remaining }, :finish)

      described_class.new.perform(bulk_import.id)
    end
  end
end
