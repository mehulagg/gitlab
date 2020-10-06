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

        def loaders(klass)
          add_attribute(:loaders, klass)
        end

        def add_attribute(sym, attribute)
          class_attributes[sym] ||= []
          class_attributes[sym] << attribute
        end
      end
    end
  end
end
