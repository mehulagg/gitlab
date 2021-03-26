# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module CiCd
        module MenuItems
          class Jobs < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_jobs_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                class: 'shortcuts-builds'
              }
            end

            override :active_routes
            def active_routes
              { controller: :jobs }
            end

            override :item_name
            def item_name
              _('Jobs')
            end

            override :render?
            def render?
              can?(context.current_user, :read_build, context.project)
            end
          end
        end
      end
    end
  end
end
