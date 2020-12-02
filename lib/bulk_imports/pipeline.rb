# frozen_string_literal: true

module BulkImports
  module Pipeline
    extend ActiveSupport::Concern
    include Gitlab::ClassAttributes

    class_methods do
      def extractor(klass, options = nil)
        add_attribute(:extractors, klass.new(options))
      end

      def transformer(klass, options = nil)
        add_attribute(:transformers, klass.new(options))
      end

      def loader(klass, options = nil)
        add_attribute(:loaders, klass.new(options))
      end

      def after_run(&block)
        class_attributes[:after_run] = block
      end

      def extractors
        class_attributes[:extractors]
      end

      def transformers
        class_attributes[:transformers]
      end

      def loaders
        class_attributes[:loaders]
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

      def add_attribute(sym, object)
        class_attributes[sym] ||= []
        class_attributes[sym] << object
      end
    end
  end
end
