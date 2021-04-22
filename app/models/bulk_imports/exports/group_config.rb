# frozen_string_literal: true

module BulkImports
  module Exports
    class GroupConfig < Config
      def import_export_yaml
        ::Gitlab::ImportExport.group_config_file
      end

      def export_path
        exportable.full_path
      end

      def ability
        :admin_group
      end
    end
  end
end
