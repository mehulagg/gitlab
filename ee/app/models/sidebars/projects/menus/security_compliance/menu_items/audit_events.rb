# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module SecurityCompliance
        module MenuItems
          class AuditEvents < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_audit_events_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                data: { qa_selector: 'audit_events_settings_link' }
              }
            end

            override :active_routes
            def active_routes
              { controller: :audit_events }
            end

            override :item_name
            def item_name
              _('Audit Events')
            end

            override :render?
            def render?
              can?(context.current_user, :read_project_audit_events, context.project) &&
                (context.project.feature_available?(:audit_events) || context.show_promotions)
            end
          end
        end
      end
    end
  end
end
