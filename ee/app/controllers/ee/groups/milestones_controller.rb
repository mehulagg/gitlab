# frozen_string_literal: true

module EE
  module Groups
    module MilestonesController
      extend ::Gitlab::Utils::Override

      override :search_params
      def search_params
        params[:only_group_milestones].present? ? super.merge(project_ids: []) : super
      end
    end
  end
end
