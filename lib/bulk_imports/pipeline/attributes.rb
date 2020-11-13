# frozen_string_literal: true

module BulkImports
  module Pipeline
    module Attributes
      extend ActiveSupport::Concern
      include Gitlab::ClassAttributes

      class_methods do
        def extractor(object, &block)
          class_attributes[:extractor] = block_given? ? block : object.method(:extract)
        end

        def transformer(object, &block)
          class_attributes[:transformers] ||= []
          class_attributes[:transformers] << block_given? ? block : object.method(:transform)
        end

        def loader(object, &block)
          class_attributes[:loader] = block_given? ? block : object.method(:load)
        end

        def attributes
          class_attributes.slice(
            :extractor,
            :transformers,
            :loaders
          )
        end

        private

        def add_attribute(sym, callback)
          class_attributes[sym] ||= []
          class_attributes[sym] << callback
        end
      end
    end
  end
end
