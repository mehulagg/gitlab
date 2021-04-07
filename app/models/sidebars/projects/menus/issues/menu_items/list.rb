# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Issues
        module MenuItems
          class List < ::Sidebars::MenuItem
            override :link
            def link
              project_issues_path(context.project)
            end

            override :extra_container_html_options
            def extra_container_html_options
              {
                aria: { label: _('Issues') }
              }
            end

            override :active_routes
            def active_routes
              { path: 'projects/issues#index' }
            end

            override :title
            def title
              _('List')
            end
          end
        end
      end
    end
  end
end
