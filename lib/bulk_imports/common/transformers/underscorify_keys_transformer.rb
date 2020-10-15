# frozen_string_literal: true

module BulkImports
  module Common
    module Transformers
      class UnderscorifyKeysTransformer
        def initialize(options = {})
          @options = options
        end

        def transform(_, data)
          data.deep_transform_keys do |key|
            key.underscore
          end
        end
      end
    end
  end
end
