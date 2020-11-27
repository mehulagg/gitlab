# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Snapshots
      class CalculateAndSaveService
        attr_reader :segment

        def initialize(segment:)
          @segment = segment
        end

        def execute
          CreateService.new(params: SnapshotCalculator.new(segment: segment).calculate).execute
        end
      end
    end
  end
end
