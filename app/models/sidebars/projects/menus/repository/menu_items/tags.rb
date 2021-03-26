# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Repository
        module MenuItems
          class Tags < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_tags_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                data: { qa_selector: 'tags_link' }
              }
            end

            override :active_routes
            def active_routes
              { controller: :tags }
            end

            override :item_name
            def item_name
              _('Tags')
            end
          end
        end
      end
    end
  end
end
