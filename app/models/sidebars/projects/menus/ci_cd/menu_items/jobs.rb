# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module CiCd
        module MenuItems
          class Jobs < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              project_jobs_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: item_name,
                class: 'shortcuts-builds'
              }
            end

            override :nav_link_params
            def nav_link_params
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
