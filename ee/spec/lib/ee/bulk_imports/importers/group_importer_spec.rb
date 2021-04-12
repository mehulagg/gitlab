# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Importers::GroupImporter do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:bulk_import) { create(:bulk_import, user: user) }
  let_it_be(:entity) { create(:bulk_import_entity, :started, bulk_import: bulk_import, group: group) }
  let_it_be(:tracker) { create(:bulk_import_tracker, entity: entity) }
  let_it_be(:context) { BulkImports::Pipeline::Context.new(tracker) }

  subject { described_class.new(entity) }

  before do
    allow(BulkImports::Pipeline::Context).to receive(:new).and_return(context)
  end

  describe '#execute' do
    it "starts the entity and run its pipelines" do
      expect_to_run_pipeline BulkImports::Groups::Pipelines::GroupPipeline, context: context
      expect_to_run_pipeline BulkImports::Groups::Pipelines::SubgroupEntitiesPipeline, context: context
      expect_to_run_pipeline BulkImports::Groups::Pipelines::MembersPipeline, context: context
      expect_to_run_pipeline BulkImports::Groups::Pipelines::LabelsPipeline, context: context
      expect_to_run_pipeline BulkImports::Groups::Pipelines::MilestonesPipeline, context: context
      expect_to_run_pipeline BulkImports::Groups::Pipelines::EpicsPipeline, context: context
      expect_to_run_pipeline BulkImports::Groups::Pipelines::EpicAwardEmojiPipeline, context: context
      expect_to_run_pipeline BulkImports::Groups::Pipelines::EpicEventsPipeline, context: context
      expect_to_run_pipeline BulkImports::Groups::Pipelines::IterationsPipeline, context: context

      subject.execute

      expect(entity.reload).to be_finished
    end
  end

  def expect_to_run_pipeline(klass, context:)
    expect_next_instance_of(klass, context) do |pipeline|
      expect(pipeline).to receive(:run)
    end
  end
end
