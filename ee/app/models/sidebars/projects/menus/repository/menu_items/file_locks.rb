# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Repository
        module MenuItems
          class FileLocks < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_path_locks_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                data: { qa_selector: 'path_locks_link' }
              }
            end

            override :nav_link_params
            def nav_link_params
              { controller: :path_locks }
            end

            override :item_name
            def item_name
              _('Locked Files')
            end

            override :render?
            def render?
              context.project.feature_available?(:file_locks)
            end
          end
        end
      end
    end
  end
end
