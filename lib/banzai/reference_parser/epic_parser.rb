# frozen_string_literal: true

module Banzai
  module ReferenceParser
    # The actual parser is implemented in the EE mixin
    class EpicParser < IssuableParser
      self.reference_type = :epic

      def records_for_nodes(_nodes)
        {}
      end
    end
  end
end

Banzai::ReferenceParser::EpicParser.prepend_mod_with('Banzai::ReferenceParser::EpicParser')
