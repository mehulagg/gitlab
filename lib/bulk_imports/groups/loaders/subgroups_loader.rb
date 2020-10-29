# frozen_string_literal: true

module BulkImports
  module Groups
    module Loaders
      class SubgroupsLoader
        def initialize(*args); end

        def load(context, entities)
          bulk_import = context.entity.bulk_import

          entities.each do |entity|
            bulk_import.entities.create!(
              source_type: entity[:source_type],
              source_full_path: entity[:source_full_path],
              destination_name: entity[:destination_name],
              destination_namespace: entity[:destination_namespace],
              parent_id: entity[:parent_id]
            )
          end
        end
      end
    end
  end
end
