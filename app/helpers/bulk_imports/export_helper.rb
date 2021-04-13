# frozen_string_literal: true

module BulkImports
  module ExportHelper
    extend self

    def exportable_relations(exportable_class)
      yaml = import_export_yaml(exportable_class)
      config = ::Gitlab::ImportExport::Config.new(config: yaml).to_h
      sym = exportable_class.to_s.downcase.to_sym

      config.dig(:tree, sym).keys.map(&:to_s)
    end

    def import_export_yaml(exportable_class)
      case exportable_class
      when 'Project'
        ::Gitlab::ImportExport.config_file
      when 'Group'
        ::Gitlab::ImportExport.group_config_file
      end
    end
  end
end
