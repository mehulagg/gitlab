# frozen_string_literal: true

module Ci
  module PipelineArtifacts
    class CodeQualityPresenter < ProcessablePresenter
      include Gitlab::Utils::StrongMemoize

      def for_files(filenames)
        codequality_files = raw_report[:degradations].values.each_with_object({}) do |degradation, codequality_files|
          if filenames.include?(degradation.dig(:location, :path))
            if codequality_files[degradation.dig(:location, :path)].present?
              codequality_files[degradation.dig(:location, :path)] << {
                line: degradation.dig(:location, :lines, :begin) || degradation.dig(:location, :positions, :begin, :line),
                description: degradation[:description],
                severity: degradation[:severity]
              }
            else
              codequality_files[degradation.dig(:location, :path)] = []
              codequality_files[degradation.dig(:location, :path)] << {
                line: degradation.dig(:location, :lines, :begin) || degradation.dig(:location, :positions, :begin, :line),
                description: degradation[:description],
                severity: degradation[:severity]
              }
            end
          end
        end

        { files: codequality_files }
      end

      private

      def raw_report
        strong_memoize(:raw_report) do
          self.each_blob do |blob|
            Gitlab::Json.parse(blob).with_indifferent_access
          end
        end
      end
    end
  end
end
