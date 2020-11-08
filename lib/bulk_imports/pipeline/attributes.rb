# frozen_string_literal: true

module BulkImports
  module Pipeline
    module Attributes
      extend ActiveSupport::Concern
      include Gitlab::ClassAttributes

      class_methods do
        def extractor(obj = nil, &block)
          if block_given?
            add_attribute(:extractors, block)
          else
            add_attribute(:extractors, obj.method(:extract))
          end
        end

        def transformer(obj = nil, &block)
          if block_given?
            add_attribute(:transformers, block)
          else
            add_attribute(:transformers, obj.method(:transform))
          end
        end

        def loader(obj = nil, &block)
          if block_given?
            add_attribute(:loaders, block)
          else
            add_attribute(:loaders, obj.method(:load))
          end
        end

        def add_attribute(sym, callback)
          class_attributes[sym] ||= []
          class_attributes[sym] << callback
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
