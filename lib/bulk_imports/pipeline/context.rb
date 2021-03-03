# frozen_string_literal: true

module BulkImports
  module Pipeline
    class Context
      attr_accessor :extra

      attr_reader :tracker

      def initialize(tracker, extra = {})
        @tracker = tracker
        @extra = extra
      end

      def entity
        tracker.entity
      end

      def group
        entity.group
      end

      def bulk_import
        entity.bulk_import
      end

      def current_user
        bulk_import.user
      end

      def configuration
        bulk_import.configuration
      end
    end
  end
end
