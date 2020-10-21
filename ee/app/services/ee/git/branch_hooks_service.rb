# frozen_string_literal: true

module EE
  module Git
    module BranchHooksService
      extend ::Gitlab::Utils::Override

      private

      override :pipeline_options
      def pipeline_options
        mirror_update = project.mirror? &&
          project.repository.up_to_date_with_upstream?(branch_name)

        { mirror_update: mirror_update }
      end
    end
  end
end
