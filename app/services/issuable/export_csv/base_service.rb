# frozen_string_literal: true

module Issuable
  module ExportCsv
    class BaseService
      # Target attachment size before base64 encoding
      TARGET_FILESIZE = 15.megabytes

      attr_reader :project

      def initialize(issuables_relation, project)
        @issuables = issuables_relation
        @project = project
      end

      def csv_data
        csv_builder.render(TARGET_FILESIZE)
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def csv_builder
        @csv_builder ||=
          CsvBuilder.new(@issuables.preload(associations_to_preload), header_to_value_hash)
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def email(user)
        # defined in ExportCsvService
      end

      private

      def associations_to_preload
        [] # defined in ExportCsvService
      end

      def header_to_value_hash
        {} # defined in ExportCsvService
      end
    end
  end
end
