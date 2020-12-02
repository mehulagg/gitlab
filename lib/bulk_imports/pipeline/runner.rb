# frozen_string_literal: true

module BulkImports
  module Pipeline
    class Runner
      MarkedAsFailedError = Class.new(StandardError)

      def self.run(context, pipelines)
        pipelines.each do |pipeline|
          new(context, pipeline).run
        end
      end

      def initialize(context, pipeline_name)
        @context = context
        @pipeline = pipeline_name
        @pipeline_class = pipeline_name.constantize
        @extractors = pipeline_class.extractors
        @transformers = pipeline_class.transformers
        @loaders = pipeline_class.loaders
        @after_run = pipeline_class.after_run
      end

      def run
        raise MarkedAsFailedError if marked_as_failed?

        info(message: 'Pipeline started', pipeline_class: pipeline)

        extractors.each do |extractor|
          data = run_pipeline_step(:extractor, extractor.class.name) do
            extractor.extract(context)
          end

          if data && data.respond_to?(:each)
            data.each do |entry|
              transformers.each do |transformer|
                entry = run_pipeline_step(:transformer, transformer.class.name) do
                  transformer.transform(context, entry)
                end
              end

              loaders.each do |loader|
                run_pipeline_step(:loader, loader.class.name) do
                  loader.load(context, entry)
                end
              end
            end
          end
        end

        after_run.call(context) if after_run.present?
      rescue MarkedAsFailedError
        log_skip
      end

      private # rubocop:disable Lint/UselessAccessModifier

      attr_reader :pipeline, :pipeline_class, :context, :extractors, :transformers, :loaders, :after_run

      def run_pipeline_step(type, class_name)
        raise MarkedAsFailedError if marked_as_failed?

        info(type => class_name)

        yield
      rescue MarkedAsFailedError
        log_skip(type => class_name)
      rescue => e
        log_import_failure(e)

        mark_as_failed if pipeline_class.abort_on_failure?
      end

      def mark_as_failed
        warn(message: 'Pipeline failed', pipeline_class: pipeline)

        context.entity.fail_op!
      end

      def marked_as_failed?
        return true if context.entity.failed?

        false
      end

      def log_skip(extra = {})
        log = {
          message: 'Skipping due to failed pipeline status',
          pipeline_class: pipeline
        }.merge(extra)

        info(log)
      end

      def log_import_failure(exception)
        attributes = {
          bulk_import_entity_id: context.entity.id,
          pipeline_class: pipeline,
          exception_class: exception.class.to_s,
          exception_message: exception.message.truncate(255),
          correlation_id_value: Labkit::Correlation::CorrelationId.current_or_new_id
        }

        BulkImports::Failure.create(attributes)
      end

      def warn(extra = {})
        logger.warn(log_base_params.merge(extra))
      end

      def info(extra = {})
        logger.info(log_base_params.merge(extra))
      end

      def log_base_params
        {
          bulk_import_entity_id: context.entity.id,
          bulk_import_entity_type: context.entity.source_type
        }
      end

      def logger
        @logger ||= Gitlab::Import::Logger.build
      end
    end
  end
end
