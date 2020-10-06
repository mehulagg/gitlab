# frozen_string_literal: true

module Gitlab
  module BulkImport
    module Common
      module Transformers
        class UnderscorifyKeysTransformer
          def self.transform(_, data)
            data.deep_transform_keys do |key|
              key.underscore
            end
          end
        end
      end
    end
  end
end
