# frozen_string_literal: true

module EE
  module BulkImports
    module Stage
      extend ::Gitlab::Utils::Override

      override :pipelines
      def pipelines
        super + [
          EE::BulkImports::Groups::Pipelines::EpicsPipeline,
          [
            EE::BulkImports::Groups::Pipelines::EpicAwardEmojiPipeline,
            EE::BulkImports::Groups::Pipelines::EpicEventsPipeline,
            EE::BulkImports::Groups::Pipelines::IterationsPipeline
          ]
        ]
      end
    end
  end
end
