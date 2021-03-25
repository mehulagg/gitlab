# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module ProjectOverview
        class Menu < ::Sidebars::Menu
          def initialize(context)
            super

            add_item(MenuItems::Details.new(context))
            add_item(MenuItems::Activity.new(context))
            add_item(MenuItems::Releases.new(context))
          end

          override :link_to_href
          def link_to_href
            project_path(context.project)
          end

          override :link_to_attributes
          def link_to_attributes
            {
              class: 'shortcuts-project rspec-project-link',
              data: { qa_selector: 'project_link' }
            }
          end

          # override :nav_link_params
          # def nav_link_params
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
