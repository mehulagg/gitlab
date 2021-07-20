# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Pipeline::EpicBase do
  let(:pipeline_class) do
    Class.new(BulkImports::Pipeline::EpicBase) do
      def extract(_)
        ::BulkImports::Pipeline::ExtractedData.new
      end

      def transform(_, data)
        data
      end

      def load(_, data)
        data
      end
    end
  end

  subject { MyPipeline.new(context) }

  before do
    stub_const('MyPipeline', pipeline_class)
  end

  context 'when the group was not imported' do
    let_it_be(:pipeline_tracker) { create(:bulk_import_tracker) }
    let_it_be(:context) { BulkImports::Pipeline::Context.new(pipeline_tracker) }

    it 'skips the pipeline' do
      expect_next_instance_of(Gitlab::Import::Logger) do |logger|
        expect(logger).to receive(:warn)
          .with(
            bulk_import_id: pipeline_tracker.entity.bulk_import.id,
            bulk_import_entity_id: pipeline_tracker.entity.id,
            bulk_import_entity_type: pipeline_tracker.entity.source_type,
            message: 'Skipping because bulk import has no group',
            pipeline_class: 'MyPipeline'
          )
      end

      expect { subject.run }
        .to change(pipeline_tracker, :status_name).to(:skipped)
    end
  end

  context 'when the group was already imported' do
    let_it_be(:group) { create(:group) }
    let_it_be(:entity) { create(:bulk_import_entity, group: group) }
    let_it_be(:pipeline_tracker) { create(:bulk_import_tracker, entity: entity) }
    let_it_be(:context) { BulkImports::Pipeline::Context.new(pipeline_tracker) }

    context 'when the group has no epics' do
      it 'skips the pipeline' do
        expect_next_instance_of(Gitlab::Import::Logger) do |logger|
          expect(logger).to receive(:warn)
            .with(
              bulk_import_id: entity.bulk_import.id,
              bulk_import_entity_id: entity.id,
              bulk_import_entity_type: entity.source_type,
              context_extra: { epic_iid: nil },
              message: 'Skipping because group has no epics',
              pipeline_class: 'MyPipeline'
            )
        end

        expect { subject.run }
          .to change(pipeline_tracker, :status_name).to(:skipped)
      end
    end

    context 'when the group has one epic with one page of data' do
      it 'runs the pipeline for each epic' do
        create(:epic, group: group)

        expect(subject)
          .to receive(:run)
          .once
          .and_call_original

        subject.run
      end
    end

    context 'when the group has one epic with multiple page of data' do
      it 'runs the pipeline for page' do
        create(:epic, group: group)

        first_page = ::BulkImports::Pipeline::ExtractedData.new(page_info: {
          'has_next_page' => true,
          'next_page' => 'page'
        })
        last_page = ::BulkImports::Pipeline::ExtractedData.new(page_info: {
          'has_next_page' => false
        })

        expect(subject)
          .to receive(:extract)
          .and_return(first_page, last_page)

        expect(subject)
          .to receive(:run)
          .twice
          .and_call_original

        subject.run
      end
    end

    context 'when the group has multiple epics with one page of data' do
      it 'runs the pipeline once for each epic' do
        create(:epic, group: group)
        create(:epic, group: group)

        expect(subject)
          .to receive(:run)
          .twice
          .and_call_original

        subject.run
      end
    end

    context 'when the group has multiple epics with multiple pages of data' do
      it 'runs the pipeline once for each page of each epic' do
        create(:epic, group: group)
        create(:epic, group: group)

        first_page = ::BulkImports::Pipeline::ExtractedData.new(page_info: {
          'has_next_page' => true,
          'next_page' => 'page'
        })
        last_page = ::BulkImports::Pipeline::ExtractedData.new(page_info: {
          'has_next_page' => false
        })

        expect(subject)
          .to receive(:extract)
          .and_return(
            first_page, # first epic
            last_page,  # first epic
            first_page, # last epic
            last_page   # last epic
          )

        expect(subject)
          .to receive(:run)
          .exactly(4).times
          .and_call_original

        subject.run
      end
    end
  end
end
