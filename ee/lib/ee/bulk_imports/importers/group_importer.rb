# frozen_string_literal: true

module EE
  module BulkImports
    module Importers
      module GroupImporter
        extend ::Gitlab::Utils::Override

        private

        override :pipelines
        def pipelines
          {
            stage_1: ::BulkImports::Groups::Pipelines::GroupPipeline,
            stage_2: [
              ::BulkImports::Groups::Pipelines::SubgroupEntitiesPipeline,
              ::BulkImports::Groups::Pipelines::MembersPipeline,
              ::BulkImports::Groups::Pipelines::LabelsPipeline
            ],
            stage_3: [
              EE::BulkImports::Groups::Pipelines::EpicsPipeline,
              EE::BulkImports::Groups::Pipelines::EpicAwardEmojiPipeline,
              EE::BulkImports::Groups::Pipelines::EpicEventsPipeline
            ]
          }
        end
      end
    end
  end
end
