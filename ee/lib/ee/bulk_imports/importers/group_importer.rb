# frozen_string_literal: true

module EE
  module BulkImports
    module Importers
      module GroupImporter
        extend ::Gitlab::Utils::Override

        private

        override :pipelines
        def stages
          [
            ::BulkImports::Groups::Pipelines::GroupPipeline,
            [
              ::BulkImports::Groups::Pipelines::SubgroupEntitiesPipeline,
              ::BulkImports::Groups::Pipelines::LabelsPipeline
            ],
            EE::BulkImports::Groups::Pipelines::EpicsPipeline,
            ::BulkImports::Importers::GroupImporter::EntityFinisher
          ]
        end
      end
    end
  end
end
