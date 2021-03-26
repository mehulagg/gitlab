# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Issues
        module MenuItems
          class Labels < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_labels_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                class: 'qa-labels-link'
              }
            end

            override :active_routes
            def active_routes
              { controller: :labels }
            end

            override :item_name
            def item_name
              _('Labels')
            end
          end
        end
      end
    end
  end
end
