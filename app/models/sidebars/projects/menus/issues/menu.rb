# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Issues
        class Menu < ::Sidebars::Menu
          def initialize(context)
            super

            add_item(MenuItems::List.new(context))
            add_item(MenuItems::Boards.new(context))
            add_item(MenuItems::Labels.new(context))
            add_item(MenuItems::ServiceDesk.new(context))
            add_item(MenuItems::Milestones.new(context))
          end

          override :link_to_href
          def link_to_href
            project_issues_path(context.project)
          end

          override :link_to_attributes
          def link_to_attributes
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
            context.project.open_issues_count(context.current_user)
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
