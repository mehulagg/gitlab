# frozen_string_literal: true

module EE
  module Nav
    module TopNavHelper
      extend ::Gitlab::Utils::Override

      private

      override :build_view_model
      def build_view_model(builder)
        super(builder)

        if dashboard_nav_link?(:environments)
          builder.add_primary_menu_item(
            id: 'environments',
            title: 'Environments',
            icon: 'environment',
            href: operations_environments_path
          )
        end

        if dashboard_nav_link?(:operations)
          builder.add_primary_menu_item(
            id: 'operations',
            title: 'Operations',
            icon: 'cloud-gear',
            href: operations_path
          )
        end

        if dashboard_nav_link?(:security)
          builder.add_primary_menu_item(
            id: 'security',
            title: 'Security',
            icon: 'shield',
            href: security_dashboard_path
          )
        end
      end
    end
  end
end
