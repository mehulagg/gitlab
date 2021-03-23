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

        private

        def valid_degradation?(degradation)
          schema_validator.valid?(degradation).tap do |valid|
            set_error_message("Invalid degradation format") unless valid
          end
        end

        def schema_validator
          JSONSchemer.schema(Pathname.new(CODECLIMATE_SCHEMA_PATH))
        end
      end
    end
  end
end
