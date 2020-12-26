# frozen_string_literal: true

module BulkImports
  module Pipeline
    extend ActiveSupport::Concern
    include Runner

    def clean_prohibited_attributes(context, data)
      Common::Transformers::ProhibitedAttributesTransformer
        .transform(context, data)
    end
  end
end
