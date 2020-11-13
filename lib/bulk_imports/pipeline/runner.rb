# frozen_string_literal: true

module BulkImports
  module Pipeline
    module Runner
      extend ActiveSupport::Concern

      included do
        def initialize
          @extractors = self.class.extractors.map(&method(:instantiate))
          @transformers = self.class.transformers.map(&method(:instantiate))
          @loaders = self.class.loaders.map(&method(:instantiate))
          @after_run = self.class.after_run_callback

          super
        end

        def run(context)
          raw_data = extractors.map do |extractor|
            extractor.extract(context)
          end

          raw_data.each do |entry|
            transformers.each do |transformer|
              entry = transformer.transform(context, entry)
            end

            loaders.each do |loader|
              loader.load(context, entry)
            end
          end

          after_run.call(context, raw_data) if after_run.present?
        end

        private

        attr_reader :extractors, :transformers, :loaders, :after_run

        def instantiate(class_config)
          class_config[:klass].new(class_config[:options])
        end
      end
    end
  end
end
