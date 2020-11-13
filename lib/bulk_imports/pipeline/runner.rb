# frozen_string_literal: true

module BulkImports
  module Pipeline
    module Runner
      extend ActiveSupport::Concern

      included do
        private

        def extractor
          @extractor ||= self.class.attributes[:extractor]
        end

        def transformers
          @transformers ||= self.class.attributes[:transformers]
        end

        def loader
          @loader ||= self.class.attributes[:loader]
        end

        def pipeline_name
          @pipeline ||= self.class.name
        end
      end

      def run(context)
        raw_data = extractor.call(context)

        raw_data.each do |entry|
          transformed = transformers.reduce do |result, transformer|
            transformer.call(context, entry)
          end

          loader.call(context, transformed)
        end
      end
    end

    def instantiate(class_config)
      class_config[:klass].new(class_config[:options])
    end
  end
end
