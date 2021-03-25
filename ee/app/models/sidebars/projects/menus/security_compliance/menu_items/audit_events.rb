# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module SecurityCompliance
        module MenuItems
          class AuditEvents < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              project_audit_events_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: item_name,
                data: { qa_selector: 'audit_events_settings_link' }
              }
            end

            override :nav_link_params
            def nav_link_params
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
