# frozen_string_literal: true

module BulkImports
  module Pipeline
    extend ActiveSupport::Concern
    include Gitlab::ClassAttributes
    include Runner

    included do
      private

      def transform(entry)
        self.class.transformers.reduce(entry) do |entry, transformer|
          instantiate(transformer).transform(context, entry)
        end
      end

      def pipeline
        @pipeline ||= self.class.name
      end

      def instantiate(class_config)
        class_config[:klass].new(class_config[:options])
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

      def get_extractor
        class_attributes[:extractor]
      end

      def transformers
        class_attributes[:transformers]
      end

      def get_loader
        class_attributes[:loader]
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
