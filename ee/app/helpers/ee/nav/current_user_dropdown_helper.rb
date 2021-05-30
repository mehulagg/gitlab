# frozen_string_literal: true

module EE
  module Nav
    module CurrentUserDropdownHelper
      extend ::Gitlab::Utils::Override

      private

      override :buy_pipeline_minutes_menu_item
      def buy_pipeline_minutes_menu_item(project:, namespace:)
        return unless show_buy_pipeline_minutes?(project, namespace)

        link_text = s_("CurrentUser|Buy Pipeline minutes")
        link_emoji = 'clock9'
        link_class = 'ci-minutes-emoji js-buy-pipeline-minutes-link'
        root_namespace = root_ancestor_namespace(project, namespace)
        data_attributes = { 'track-event': 'click_buy_ci_minutes', 'track-label': root_namespace.actual_plan_name, 'track-property': 'user_dropdown' }
        path = usage_quotas_path(root_namespace)


      end
    end
  end
end
