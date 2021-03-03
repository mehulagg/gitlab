# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Importers::GroupImporter do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:bulk_import) { create(:bulk_import, user: user) }
  let(:bulk_import_entity) { create(:bulk_import_entity, :started, bulk_import: bulk_import, group: group) }
  let(:bulk_import_configuration) { create(:bulk_import_configuration, bulk_import: bulk_import) }
  let(:context) { BulkImports::Pipeline::Context.new(bulk_import_entity) }

  subject { described_class.new(bulk_import_entity) }

  before do
    allow(BulkImports::Pipeline::Context).to receive(:new).and_return(context)
  end

  describe '#execute' do
    it "starts the entity and run its pipelines" do
      expect_to_run_pipeline BulkImports::Groups::Pipelines::GroupPipeline, context: context
      expect_to_run_pipeline BulkImports::Groups::Pipelines::SubgroupEntitiesPipeline, context: context
      expect_to_run_pipeline BulkImports::Groups::Pipelines::MembersPipeline, context: context
      expect_to_run_pipeline BulkImports::Groups::Pipelines::LabelsPipeline, context: context
      expect_to_run_pipeline EE::BulkImports::Groups::Pipelines::EpicsPipeline, context: context
      expect_to_run_pipeline EE::BulkImports::Groups::Pipelines::EpicAwardEmojiPipeline, context: context

      subject.execute

      expect(bulk_import_entity.reload).to be_finished
    end
  end

  def expect_to_run_pipeline(klass, context:)
    expect_next_instance_of(klass, context) do |pipeline|
      expect(pipeline).to receive(:run)
    end
  end
end
