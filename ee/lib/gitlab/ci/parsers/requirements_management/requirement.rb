# frozen_string_literal: true
module Gitlab
  module Ci
    module Parsers
      module RequirementsManagement
        class Requirement
          RequirementParserError = Class.new(Gitlab::Ci::Parsers::ParserError)

          def parse!(json_data, report)
            result = Gitlab::Json.parse!(json_data)
            raise RequirementParserError, 'Invalid report format' unless result.is_a?(Hash)

            result.each { |ref, state| report.add_requirement(ref, state) }
          rescue JSON::ParserError
            raise RequirementParserError, 'JSON parsing failed'
          end
        end
      end
    end
  end
end
