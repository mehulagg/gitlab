# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      class CodeQualityReports
        attr_reader :degredations, :error_message

        def initialize
          @degredations = {}
          @error_message = nil
        end

        def add_degredation(fingerprint, degredation)
          @degredations[fingerprint] = degredation
        end

        def set_error_message(error)
          @error_message = error
        end
      end
    end
  end
end
