# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Repository
        module MenuItems
          class Tags < ::Sidebars::MenuItem
            override :link
            def link
              project_tags_path(context.project)
            end

            override :extra_container_html_options
            def extra_container_html_options
              {
                data: { qa_selector: 'tags_link' }
              }
            end

            override :active_routes
            def active_routes
              { controller: :tags }
            end

            override :title
            def title
              _('Tags')
            end
          end
        end
      end
    end
  end
end
