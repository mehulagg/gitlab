# frozen_string_literal: true

module BulkImports
  module Pipeline
    module Attributes
      extend ActiveSupport::Concern
      include Gitlab::ClassAttributes

      included do
        private

        def extractors
          @extractors ||= self.class.extractors.map(&method(:instantiate))
        end

        def transformers
          @transformers ||= self.class.transformers.map(&method(:instantiate))
        end

        def loaders
          @loaders ||= self.class.loaders.map(&method(:instantiate))
        end

        def pipeline_name
          @pipeline ||= self.class.name
        end

        def instantiate(class_config)
          class_config[:klass].new(class_config[:options])
        end
      end

      class_methods do
        def extractor(klass, options = nil)
          add_attribute(:extractors, klass, options)
        end

        def transformer(klass, options = nil)
          add_attribute(:transformers, klass, options)
        end

        def loader(klass, options = nil)
          add_attribute(:loaders, klass, options)
        end

        def add_attribute(sym, klass, options)
          class_attributes[sym] ||= []
          class_attributes[sym] << { klass: klass, options: options }
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
      end
    end
  end
end
