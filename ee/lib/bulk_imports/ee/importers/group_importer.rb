# frozen_string_literal: true

module BulkImports
  module EE
    module Importers
      module GroupImporter
        def pipelines
          [
            'BulkImports::Groups::Pipelines::GroupPipeline',
            'BulkImports::EE::Groups::Pipelines::EpicsPipeline',
            'BulkImports::Groups::Pipelines::SubgroupEntitiesPipeline'
          ]
        end
      end
    end
  end
end
