# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module ProjectOverview
        class Menu < ::Sidebars::Menu
          override :configure_menu_items
          def configure_menu_items
            add_item(MenuItems::Details.new(context))
            add_item(MenuItems::Activity.new(context))
            add_item(MenuItems::Releases.new(context))
          end

          override :menu_link
          def menu_link
            project_path(context.project)
          end

          override :extra_menu_container_html_options
          def extra_menu_container_html_options
            {
              class: 'shortcuts-project rspec-project-link',
              data: { qa_selector: 'project_link' }
            }
          end

          # override :active_routes
          # def active_routes
          #   { path: 'projects#show' }
          # end

          override :menu_name
          def menu_name
            _('Project overview')
          end

          override :sprite_icon
          def sprite_icon
            'home'
          end
        end
      end
    end
  end
end
