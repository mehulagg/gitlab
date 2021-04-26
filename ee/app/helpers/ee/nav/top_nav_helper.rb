# frozen_string_literal: true

module EE
  module Nav
    module TopNavHelper
      extend ::Gitlab::Utils::Override

      private

      override :top_nav_view_model_primary
      def top_nav_view_model_primary
        primary = super

        if dashboard_nav_link?(:environments)
          primary.push({
                         id: 'environments',
                         title: 'Environments',
                         icon: 'environment',
                         href: operations_environments_path
                       })
        end

        if dashboard_nav_link?(:operations)
          primary.push({
                         id: 'operations',
                         title: 'Operations',
                         icon: 'cloud-gear',
                         href: operations_path
                       })
        end

        if dashboard_nav_link?(:security)
          primary.push({
                         id: 'security',
                         title: 'Security',
                         icon: 'shield',
                         href: security_dashboard_path
                       })
        end

        primary
      end
    end
  end
end
