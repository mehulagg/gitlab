# frozen_string_literal: true

module Gitlab
  module BulkImport
    module PipelineRunner
      extend ActiveSupport::Concern

      class_methods do
        def run(context)
          extractors.each do |extractor|
            extractor.extract(context).each do |entry|
              transformers.each do |transformer|
                entry = transformer.transform(context, entry)
              end

              loaders.each do |loader|
                loader.load(context, entry)
              end
            end
          end
        end
      end
    end
  end
end
