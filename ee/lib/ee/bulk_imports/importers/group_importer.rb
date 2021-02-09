# frozen_string_literal: true

module EE
  module BulkImports
    module Importers
      module GroupImporter
        extend ::Gitlab::Utils::Override

        private

        override :pipelines
        def pipelines
          super << EE::BulkImports::Groups::Pipelines::EpicsPipeline
        end

        def importers
          super << EE::BulkImports::Importers::Groups::EpicRelationsImporter
        end
      end
    end
  end
end
