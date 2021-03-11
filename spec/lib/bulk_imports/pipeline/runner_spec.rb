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

      def transform(context); end
    end
  end

  let(:loader) do
    Class.new do
      def initialize(options = {}); end

      def load(context); end
    end
  end

  before do
    stub_const('BulkImports::Extractor', extractor)
    stub_const('BulkImports::Transformer', transformer)
    stub_const('BulkImports::Loader', loader)

    pipeline = Class.new do
      include BulkImports::Pipeline

      extractor BulkImports::Extractor
      transformer BulkImports::Transformer
      loader BulkImports::Loader

      def after_run(_); end
    end

    stub_const('BulkImports::MyPipeline', pipeline)
  end

  let_it_be_with_refind(:entity) { create(:bulk_import_entity) }
  let(:context) { BulkImports::Pipeline::Context.new(entity, extra: :data) }

  subject { BulkImports::MyPipeline.new(context) }

  describe 'pipeline runner' do
    context 'when entity is not marked as failed' do
      it 'runs pipeline extractor, transformer, loader' do
        extracted_data = BulkImports::Pipeline::ExtractedData.new(data: { foo: :bar })

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
              log_params(
                context,
                message: 'Pipeline started',
                pipeline_class: 'BulkImports::MyPipeline'
              )
            )
          expect(logger).to receive(:info)
            .with(
              log_params(
                context,
                pipeline_class: 'BulkImports::MyPipeline',
                pipeline_step: :extractor,
                step_class: 'BulkImports::Extractor'
              )
            )
          expect(logger).to receive(:info)
            .with(
              log_params(
                context,
                pipeline_class: 'BulkImports::MyPipeline',
                pipeline_step: :transformer,
                step_class: 'BulkImports::Transformer'
              )
            )
          expect(logger).to receive(:info)
            .with(
              log_params(
                context,
                pipeline_class: 'BulkImports::MyPipeline',
                pipeline_step: :loader,
                step_class: 'BulkImports::Loader'
              )
            )
          expect(logger).to receive(:info)
            .with(
              log_params(
                context,
                pipeline_class: 'BulkImports::MyPipeline',
                pipeline_step: :after_run
              )
            )
          expect(logger).to receive(:info)
            .with(
              log_params(
                context,
                message: 'Pipeline finished',
                pipeline_class: 'BulkImports::MyPipeline'
              )
            )
        end

        subject.run
      end

      context 'when exception is raised' do
        before do
          allow_next_instance_of(BulkImports::Extractor) do |extractor|
            allow(extractor).to receive(:extract).with(context).and_raise(StandardError, 'Error!')
          end
        end

        it 'logs import failure' do
          expect_next_instance_of(Gitlab::Import::Logger) do |logger|
            expect(logger).to receive(:error)
              .with(
                log_params(
                  context,
                  pipeline_step: :extractor,
                  pipeline_class: 'BulkImports::MyPipeline',
                  exception_class: 'StandardError',
                  exception_message: 'Error!'
                )
              )
          end

          expect { subject.run }
            .to change(entity.failures, :count).by(1)

          failure = entity.failures.first

          expect(failure).to be_present
          expect(failure.pipeline_class).to eq('BulkImports::MyPipeline')
          expect(failure.pipeline_step).to eq('extractor')
          expect(failure.exception_class).to eq('StandardError')
          expect(failure.exception_message).to eq('Error!')
        end

        context 'when pipeline is marked to abort on failure' do
          before do
            BulkImports::MyPipeline.abort_on_failure!
          end

          it 'marks entity as failed' do
            expect { subject.run }
              .to change(entity, :status_name).to(:failed)
          end

          it 'logs warn message' do
            expect_next_instance_of(Gitlab::Import::Logger) do |logger|
              expect(logger).to receive(:warn)
                .with(
                  log_params(
                    context,
                    message: 'Pipeline failed',
                    pipeline_class: 'BulkImports::MyPipeline'
                  )
                )
            end

            subject.run
          end
        end

        context 'when pipeline is not marked to abort on failure' do
          it 'does not mark entity as failed' do
            subject.run

            expect(entity.failed?).to eq(false)
          end
        end
      end
    end

    context 'when entity is marked as failed' do
      it 'logs and returns without execution' do
        entity.fail_op!

        expect_next_instance_of(Gitlab::Import::Logger) do |logger|
          expect(logger).to receive(:info)
            .with(
              log_params(
                context,
                message: 'Skipping due to failed pipeline status',
                pipeline_class: 'BulkImports::MyPipeline'
              )
            )
        end

        subject.run
      end
    end
  end

  def log_params(context, extra = {})
    {
      bulk_import_id: context.bulk_import.id,
      bulk_import_entity_id: context.entity.id,
      bulk_import_entity_type: context.entity.source_type,
      context_extra: context.extra
    }.merge(extra)
  end
end
