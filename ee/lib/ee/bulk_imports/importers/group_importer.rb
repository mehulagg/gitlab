# frozen_string_literal: true

module EE
  module BulkImports
    module Importers
      module GroupImporter
        extend ::Gitlab::Utils::Override

        private

        override :pipelines
        def pipelines
          super + [
            ::BulkImports::Groups::Pipelines::EpicsPipeline,
            ::BulkImports::Groups::Pipelines::EpicAwardEmojiPipeline,
            ::BulkImports::Groups::Pipelines::EpicEventsPipeline,
            ::BulkImports::Groups::Pipelines::IterationsPipeline
          ]
        end
      end
    end
  end
end
