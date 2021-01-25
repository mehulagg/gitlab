# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      class CodequalityReports
        attr_reader :degradations, :error_message

        CODECLIMATE_SCHEMA_PATH = Rails.root.join('app', 'validators', 'json_schemas', 'codeclimate.json').to_s

        def initialize
          @degradations = {}.with_indifferent_access
          @error_message = nil
        end

        def add_degradation(degradation)
          valid_degradation?(degradation) && @degradations[degradation.dig('fingerprint')] = degradation
        end

        def set_error_message(error)
          @error_message = error
        end

        def degradations_count
          @degradations.size
        end

        def all_degradations
          @degradations.values
        end

        def present_for_mr_diff
          codequality_files = all_degradations.each_with_object({}) do |degradation, codequality_files|
            unless codequality_files[degradation.dig(:location, :path)].present?
              codequality_files[degradation.dig(:location, :path)] = []
            end

            build_payload(codequality_files, degradation)
          end

          { files: codequality_files }
        end

        private

        def build_payload(codequality_files, degradation)
          codequality_files[degradation.dig(:location, :path)] << {
            line: degradation.dig(:location, :lines, :begin) || degradation.dig(:location, :positions, :begin, :line),
            description: degradation[:description],
            severity: degradation[:severity]
          }
        end

        def valid_degradation?(degradation)
          JSON::Validator.validate!(CODECLIMATE_SCHEMA_PATH, degradation)
        rescue JSON::Schema::ValidationError => e
          set_error_message("Invalid degradation format: #{e.message}")
          false
        end
      end
    end
  end
end
