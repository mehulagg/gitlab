# frozen_string_literal: true

module BulkImports
  module Pipeline
    extend ActiveSupport::Concern
    include Gitlab::ClassAttributes

    included do
      include Runner

      private

      def transformers
        @transformers ||= self.class.transformers.map do |config|
          config[:klass].new(config[:options])
        end
      end

      def after_run
        @after_run ||= self.class.after_run_callback
      end

      def pipeline
        @pipeline ||= self.class.name
      end

      def instantiate(class_config)
      end

      def abort_on_failure?
        self.class.abort_on_failure?
      end
    end

    class_methods do
      def transformer(klass, options = nil)
        add_attribute(:transformers, klass, options)
      end

      def after_run(&block)
        class_attributes[:after_run] = block
      end

      def transformers
        class_attributes[:transformers]
      end

      def after_run_callback
        class_attributes[:after_run]
      end

      def abort_on_failure!
        class_attributes[:abort_on_failure] = true
      end

      def abort_on_failure?
        class_attributes[:abort_on_failure]
      end

      private

      def add_attribute(sym, klass, options)
        class_attributes[sym] ||= []
        class_attributes[sym] << { klass: klass, options: options }
      end
    end
  end
end
