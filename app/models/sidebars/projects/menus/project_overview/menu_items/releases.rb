# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module ProjectOverview
        module MenuItems
          class Releases < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_releases_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                class: 'shortcuts-project-releases'
              }
            end

            override :render?
            def render?
              !context.project.empty_repo? && can?(context.current_user, :read_release, context.project)
            end

            override :active_routes
            def active_routes
              { controller: :releases }
            end

            override :item_name
            def item_name
              _('Releases')
            end
          end
        end
      end
    end
  end
end
