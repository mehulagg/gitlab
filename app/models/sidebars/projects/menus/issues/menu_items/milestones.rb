# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Issues
        module MenuItems
          class Milestones < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_milestones_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                class: 'qa-milestones-link'
              }
            end

            override :active_routes
            def active_routes
              { controller: :milestones }
            end

            override :item_name
            def item_name
              _('Milestones')
            end
          end
        end
      end
    end
  end
end
