# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Snapshots
      class CalculateAndSaveService
        attr_reader :segment, :range_end

        def initialize(segment:, range_end: Time.zone.now)
          @segment = segment
          @range_end = range_end
        end

        def execute
          CreateService.new(params: SnapshotCalculator.new(segment: segment, range_end: range_end).calculate).execute
        end
      end
    end
  end
end
