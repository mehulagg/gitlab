# frozen_string_literal: true

module Elastic
  module Latest
    module CustomLanguageAnalyzers
      extend self

      def custom_analyzers_fields(type:)
        {}.tap do |hash|
          custom_analyzers_enabled.each do |analyzer|
            hash[analyzer.to_sym] = {
              analyzer: analyzer,
              type: type
            }
          end
        end
      end

      def custom_analyzers_enabled
        [].tap do |enabled|
          enabled << 'smartcn' if ApplicationSetting.current.elasticsearch_analyzers_smartcn_enabled
          enabled << 'kuromoji' if ApplicationSetting.current.elasticsearch_analyzers_kuromiji_enabled
        end
      end

      def custom_analyzers_search
        [].tap do |enabled|
          enabled << 'smartcn' if ApplicationSetting.current.elasticsearch_analyzers_smartcn_search
          enabled << 'kuromoji' if ApplicationSetting.current.elasticsearch_analyzers_kuromiji_search
        end
      end
    end
  end
end
