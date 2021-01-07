# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Snapshots
      class CalculateAndSaveService
        attr_reader :segment, :range_end

        def initialize(segment:, range_end:)
          @segment = segment
          @range_end = range_end
        end

        def execute
          if snapshot
            UpdateService.new(snapshot: snapshot, params: calculated_data).execute
          else
            CreateService.new(params: calculated_data).execute
          end
        end

        def snapshot
          @snapshot ||= segment.snapshots.for_month(range_end).first
        end

        def calculated_data
          @calculated_data ||= SnapshotCalculator.new(segment: segment, range_end: range_end, snapshot: snapshot).calculate
        end
      end
    end
  end
end
