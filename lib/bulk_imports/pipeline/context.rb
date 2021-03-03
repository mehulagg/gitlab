# frozen_string_literal: true

module BulkImports
  module Pipeline
    class Context
      attr_reader :tracker, :entity, :bulk_import
      attr_accessor :extra

      def initialize(tracker, extra = {})
        @tracker = tracker
        @entity = tracker.entity
        @bulk_import = entity.bulk_import
        @extra = extra
      end

      def group
        entity.group
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
