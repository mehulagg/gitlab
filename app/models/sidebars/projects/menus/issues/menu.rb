# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Issues
        class Menu < ::Sidebars::Menu
          override :configure_menu_items
          def configure_menu_items
            add_item(MenuItems::List.new(context))
            add_item(MenuItems::Boards.new(context))
            add_item(MenuItems::Labels.new(context))
            add_item(MenuItems::ServiceDesk.new(context))
            add_item(MenuItems::Milestones.new(context))
          end

          override :menu_link
          def menu_link
            project_issues_path(context.project)
          end

          override :extra_menu_container_html_options
          def extra_menu_container_html_options
            {
              class: 'shortcuts-issues qa-issues-item'
            }
          end

          override :menu_name
          def menu_name
            _('Issues')
          end

          override :menu_name_html_options
          def menu_name_html_options
            {
              id: 'js-onboarding-issues-link'
            }
          end

          override :sprite_icon
          def sprite_icon
            'issues'
          end

          override :render?
          def render?
            can?(context.current_user, :read_issue, context.project)
          end

          override :has_pill?
          def has_pill?
            context.project.issues_enabled?
          end

          override :pill_count
          def pill_count
            @pill_count ||= context.project.open_issues_count(context.current_user)
          end

          override :pill_html_options
          def pill_html_options
            {
              class: 'issue_counter'
            }
          end
        end
      end
    end
  end
end

Sidebars::Projects::Menus::Issues::Menu.prepend_if_ee('EE::Sidebars::Projects::Menus::Issues::Menu')
