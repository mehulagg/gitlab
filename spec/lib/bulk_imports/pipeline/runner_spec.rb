# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Pipeline::Runner do
  let(:extractor) do
    Class.new do
      def initialize(options = {}); end

      def extract(context); end
    end
  end

  let(:transformer) do
    Class.new do
      def initialize(options = {}); end

      def transform(context, data); end
    end
  end

  let(:loader) do
    Class.new do
      def initialize(options = {}); end

      def load(context, data); end
    end
  end

  let(:entity) { create(:bulk_import_entity) }

  let(:tracker) do
    create(
      :bulk_import_tracker,
      entity: entity,
      pipeline_name: 'BulkImports::MyPipeline'
    )
  end

  let(:context) { BulkImports::Pipeline::Context.new(tracker) }

  subject { BulkImports::MyPipeline.new(context) }

  before do
    stub_const('BulkImports::Extractor', extractor)
    stub_const('BulkImports::Transformer', transformer)
    stub_const('BulkImports::Loader', loader)

    pipeline = Class.new do
      include BulkImports::Pipeline

      extractor BulkImports::Extractor
      transformer BulkImports::Transformer
      loader BulkImports::Loader
    end

    stub_const('BulkImports::MyPipeline', pipeline)
  end

  it 'runs all pipeline steps' do
    expect_next_instance_of(BulkImports::Extractor) do |extractor|
      expect(extractor)
        .to receive(:extract)
        .with(context)
        .and_return(extracted_data)
    end

    expect_next_instance_of(BulkImports::Transformer) do |transformer|
      expect(transformer)
        .to receive(:transform)
        .with(context, extracted_data.data.first)
        .and_return(extracted_data.data.first)
    end

    expect_next_instance_of(BulkImports::Loader) do |loader|
      expect(loader)
        .to receive(:load)
        .with(context, extracted_data.data.first)
    end

    expect_next_instance_of(Gitlab::Import::Logger) do |logger|
      expect(logger).to receive(:info)
        .with(
          message: 'Pipeline started',
          bulk_import_entity_id: entity.id,
          bulk_import_entity_type: 'group_entity',
          pipeline_class: 'BulkImports::MyPipeline'
        )
      expect(logger).to receive(:info)
        .with(
          pipeline_step: :extractor,
          bulk_import_entity_id: entity.id,
          bulk_import_entity_type: 'group_entity',
          pipeline_class: 'BulkImports::MyPipeline',
          step_class: 'BulkImports::Extractor'
        )
      expect(logger).to receive(:info)
        .with(
          pipeline_step: :transformer,
          bulk_import_entity_id: entity.id,
          bulk_import_entity_type: 'group_entity',
          pipeline_class: 'BulkImports::MyPipeline',
          step_class: 'BulkImports::Transformer'
        )
      expect(logger).to receive(:info)
        .with(
          pipeline_step: :loader,
          bulk_import_entity_id: entity.id,
          bulk_import_entity_type: 'group_entity',
          pipeline_class: 'BulkImports::MyPipeline',
          step_class: 'BulkImports::Loader'
        )
      expect(logger).to receive(:info)
        .with(
          pipeline_step: :after_run,
          bulk_import_entity_id: entity.id,
          bulk_import_entity_type: 'group_entity',
          pipeline_class: 'BulkImports::MyPipeline'
        )
      expect(logger).to receive(:info)
        .with(
          message: 'Pipeline finished',
          bulk_import_entity_id: entity.id,
          bulk_import_entity_type: 'group_entity',
          pipeline_class: 'BulkImports::MyPipeline'
        )
    end

    subject.run
  end

  context 'when extracted data has multiple pages' do
    it 'updates tracker information and runs pipeline again' do
      first_page = extracted_data(has_next_page: true)
      last_page = extracted_data(has_next_page: false)

      expect_next_instance_of(BulkImports::Extractor) do |extractor|
        expect(extractor)
          .to receive(:extract)
          .with(context)
          .and_return(first_page, last_page)
      end

      subject.run
    end
  end

  context 'when exception is raised' do
    before do
      allow_next_instance_of(BulkImports::Extractor) do |extractor|
        allow(extractor)
          .to receive(:extract)
          .with(context)
          .and_raise(StandardError, 'Error!')
      end
    end

    it 'logs import failure' do
      expect { subject.run }
        .to change(tracker, :status_name).to(:failed)
        .and change(entity.failures, :count).by(1)

      # Ensure that it doesn't change entity status
      expect(entity.status_name).to eq(:created)

      failure = entity.failures.first

      expect(failure).to be_present
      expect(failure.pipeline_class).to eq('BulkImports::MyPipeline')
      expect(failure.pipeline_step).to eq('extractor')
      expect(failure.exception_class).to eq('StandardError')
      expect(failure.exception_message).to eq('Error!')
    end

    context 'when pipeline is marked to abort on failure' do
      it 'marks entity as failed and log error' do
        BulkImports::MyPipeline.abort_on_failure!

        expect_next_instance_of(Gitlab::Import::Logger) do |logger|
          expect(logger).to receive(:warn)
            .with(
              message: 'Pipeline failed',
              bulk_import_entity_id: entity.id,
              bulk_import_entity_type: entity.source_type,
              pipeline_class: 'BulkImports::MyPipeline'
            )
        end

        expect { subject.run }
          .to change(entity, :status_name).to(:failed)
          .and change(tracker, :status_name).to(:failed)
          .and change(entity.failures, :count).by(1)
      end
    end
  end

  context 'when entity is marked as failed' do
    it 'skips the pipeline marking tracker as skipped and logging a message' do
      entity.fail_op

      expect_next_instance_of(Gitlab::Import::Logger) do |logger|
        expect(logger).to receive(:warn)
          .with(
            message: 'Skipping pipeline due to failed entity',
            pipeline_class: 'BulkImports::MyPipeline',
            bulk_import_entity_id: entity.id,
            bulk_import_entity_type: 'group_entity'
          )
      end

      expect { subject.run }
        .to change(tracker, :status_name).to(:skipped)
    end
  end

  def extracted_data(data: { foo: :bar }, has_next_page: false)
    BulkImports::Pipeline::ExtractedData.new(
      data: data,
      page_info: {
        'has_next_page' => has_next_page,
        'cursor' => 'cursor'
      }
    )
  end
end
