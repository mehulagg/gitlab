# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Repository
        module MenuItems
          class FileLocks < ::Sidebars::MenuItem
            override :link
            def link
              project_path_locks_path(context.project)
            end

            override :extra_container_html_options
            def extra_container_html_options
              {
                data: { qa_selector: 'path_locks_link' }
              }
            end

            override :active_routes
            def active_routes
              { controller: :path_locks }
            end

            override :title
            def title
              _('Locked Files')
            end

            override :render?
            def render?
              context.project.licensed_feature_available?(:file_locks)
            end
          end
        end
      end
    end
  end
end
