# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      class CodequalityReports
        attr_reader :degredations, :error_message

        def initialize
          @degredations = {}.with_indifferent_access
          @error_message = nil
        end

        def add_degredation(fingerprint, degredation)
          @degredations[fingerprint] = degredation
        end

        def set_error_message(error)
          @error_message = error
        end

        def degredations_count
          @degredations.size
        end

        def all_degredations
          @degredations.values
        end
      end
    end
  end
end
