# frozen_string_literal: true

module Elastic
  module Latest
    module CustomLanguageAnalyzers
      extend self

      SUPPORTED_FIELDS = %w(title description).freeze

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

      def add_custom_analyzers_fields(fields)
        return fields if custom_analyzers_search.blank?

        fields_names = fields.map { |m| m[/\w+/] }

        SUPPORTED_FIELDS.each do |field|
          next unless fields_names.include?(field)

          fields << "#{field}.smartcn" if ::Gitlab::CurrentSettings.elasticsearch_analyzers_smartcn_search
          fields << "#{field}.kuromoji" if ::Gitlab::CurrentSettings.elasticsearch_analyzers_kuromoji_search
        end

        fields
      end

      private

      def custom_analyzers_enabled
        [].tap do |enabled|
          enabled << 'smartcn' if ::Gitlab::CurrentSettings.elasticsearch_analyzers_smartcn_enabled
          enabled << 'kuromoji' if ::Gitlab::CurrentSettings.elasticsearch_analyzers_kuromoji_enabled
        end
      end

      def custom_analyzers_search
        [].tap do |analyzers|
          analyzers << 'smartcn' if ::Gitlab::CurrentSettings.elasticsearch_analyzers_smartcn_search
          analyzers << 'kuromoji' if ::Gitlab::CurrentSettings.elasticsearch_analyzers_kuromoji_search
        end
      end
    end
  end
end
