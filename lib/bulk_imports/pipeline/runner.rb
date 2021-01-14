# frozen_string_literal: true

module BulkImports
  module Pipeline
    module Runner
      extend ActiveSupport::Concern

      MarkedAsFailedError = Class.new(StandardError)

      def initialize(context)
        @context = context
      end

      def run
        raise MarkedAsFailedError if marked_as_failed?

        info(message: 'Pipeline started')

        extracted_data.each do |entry|
          entry = run_pipeline_step(:transformer) { transform(entry) }

          run_pipeline_step(:loader) { load(entry) }
        end

        if respond_to?(:after_run)
          run_pipeline_step(:after_run)
          after_run
        end

        info(message: 'Pipeline finished')
      rescue MarkedAsFailedError
        log_skip
      end

      private # rubocop:disable Lint/UselessAccessModifier

      attr_reader :context

      def extracted_data
        run_pipeline_step(:extractor) { extract }
          .then { |data| Array.wrap(data) }
      end

      def run_pipeline_step(step)
        raise MarkedAsFailedError if marked_as_failed?

        info(message: "Pipeline step", step: step)

        yield
      rescue MarkedAsFailedError
        log_skip(step: step)
      rescue => e
        log_import_failure(e)

        mark_as_failed if abort_on_failure?
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
        logger.warn(log_base_params(context).merge(extra))
      end

      def info(extra = {})
        logger.info(log_base_params.merge(extra))
      end

      def log_base_params
        {
          bulk_import_entity_id: context.entity.id,
          bulk_import_entity_type: context.entity.source_type,
          pipeline_class: pipeline
        }
      end

      def logger
        @logger ||= Gitlab::Import::Logger.build
      end
    end
  end
end
