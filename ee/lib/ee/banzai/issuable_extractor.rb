# frozen_string_literal: true

module EE
  module Banzai
    module IssuableExtractor
      EPIC_REFERENCE_TYPE = '@data-reference-type="epic"'
      VULNERABILITY_REFERENCE_TYPE = '@data-reference-type="vulnerability"'

      private

      def reference_types
        super
          .push(EPIC_REFERENCE_TYPE)
          .push(VULNERABILITY_REFERENCE_TYPE)
      end

      def parsers
        super
          .push(::Banzai::ReferenceParser::EpicParser.new(context))
          .push(::Banzai::ReferenceParser::VulnerabilityParser.new(context))
      end
    end
  end
end
