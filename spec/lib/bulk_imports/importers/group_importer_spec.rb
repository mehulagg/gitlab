# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Importers::GroupImporter do
  let(:user) { create(:user) }
  let(:bulk_import) { create(:bulk_import) }
  let(:bulk_import_entity) { create(:bulk_import_entity, bulk_import: bulk_import) }
  let(:bulk_import_configuration) { create(:bulk_import_configuration, bulk_import: bulk_import) }
  let(:context) do
    instance_double(
      BulkImports::Pipeline::Context,
      current_user: user,
      entity: bulk_import_entity,
      configuration: bulk_import_configuration
    )
  end

  subject { described_class.new(bulk_import_entity.id) }

  describe '#execute' do
    before do
      allow(BulkImports::Pipeline::Context).to receive(:new).and_return(context)
    end

    it 'executes GroupPipeline' do
      expect_next_instance_of(BulkImports::Groups::Pipelines::GroupPipeline) do |pipeline|
        expect(pipeline).to receive(:run).with(context)
      end

      subject.execute
    end
  end
end
