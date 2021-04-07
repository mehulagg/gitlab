# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Issues
        class Menu < ::Sidebars::Menu
          include Gitlab::Utils::StrongMemoize

          override :configure_menu_items
          def configure_menu_items
            add_item(MenuItems::List.new(context))
            add_item(MenuItems::Boards.new(context))
            add_item(MenuItems::Labels.new(context))
            add_item(MenuItems::ServiceDesk.new(context))
            add_item(MenuItems::Milestones.new(context))
          end

          override :link
          def link
            project_issues_path(context.project)
          end

          override :extra_container_html_options
          def extra_container_html_options
            {
              class: 'shortcuts-issues'
            }
          end

          override :title
          def title
            _('Issues')
          end

          override :title_html_options
          def title_html_options
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

          override :active_routes
          def active_routes
            { controller: 'projects/issues' }
          end

          override :has_pill?
          def has_pill?
            strong_memoize(:has_pill) do
              context.project.issues_enabled?
            end
          end

          override :pill_count
          def pill_count
            strong_memoize(:pill_count) do
              context.project.open_issues_count(context.current_user)
            end
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
