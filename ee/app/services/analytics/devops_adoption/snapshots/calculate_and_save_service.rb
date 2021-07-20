# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Snapshots
      class CalculateAndSaveService
        attr_reader :enabled_namespace, :range_end

        def initialize(enabled_namespace:, range_end:)
          @enabled_namespace = enabled_namespace
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
          @snapshot ||= enabled_namespace.snapshots.for_month(range_end).first
        end

        def calculated_data
          @calculated_data ||= SnapshotCalculator.new(enabled_namespace: enabled_namespace, range_end: range_end, snapshot: snapshot).calculate
        end
      end
    end
  end
end
