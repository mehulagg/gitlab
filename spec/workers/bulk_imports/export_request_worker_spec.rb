# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::ExportRequestWorker do
  let_it_be(:bulk_import) { create(:bulk_import) }
  let_it_be(:configuration) { create(:bulk_import_configuration, bulk_import: bulk_import) }
  let_it_be(:entity) { create(:bulk_import_entity, bulk_import: bulk_import, source_full_path: 'foo/bar') }

  let(:job_args) { entity.id }

  include_examples 'an idempotent worker' do
    describe '#perform' do
      it 'requests relations export' do
        expected = '/groups/foo%2Fbar/export_relations'

        expect_next_instance_of(BulkImports::Clients::Http) do |client|
          expect(client).to receive(:post).with(expected).twice
        end

        perform_multiple(job_args)
      end
    end
  end
end
