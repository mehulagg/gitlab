# frozen_string_literal: true

module BulkImports
  module Common
    module Transformers
      class ProhibitedAttributesTransformer
        PROHIBITED_REFERENCES = Regexp.union(
          /\Acached_markdown_version\Z/,
          /_id\Z/,
          /_ids\Z/,
          /_html\Z/,
          /attributes/,
          /\Aremote_\w+_(url|urls|request_header)\Z/ # carrierwave automatically creates these attribute methods for uploads
        ).freeze

        def initialize(options = {})
          @options = options
        end

        def transform(_, data)
          data.reject do |key, value|
            transform(_, value) if value.is_a?(Hash)

            prohibited_key?(key)
          end.except('id')
        end

        private

        def prohibited_key?(key)
          key.to_s =~ PROHIBITED_REFERENCES
        end
      end
    end
  end
end
