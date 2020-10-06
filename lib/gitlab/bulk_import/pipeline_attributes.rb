# frozen_string_literal: true

module Gitlab
  module BulkImport
    module PipelineAttributes
      extend ActiveSupport::Concern
      include Gitlab::ClassAttributes

      class_methods do
        def extractor(klass)
          add_attribute(:extractors, klass)
        end

        def transformer(klass)
          add_attribute(:transformers, klass)
        end

        def loader(klass)
          add_attribute(:loaders, klass)
        end

        def add_attribute(sym, attribute)
          class_attributes[sym] ||= []
          class_attributes[sym] << attribute
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
