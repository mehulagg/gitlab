# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module CiCd
        module MenuItems
          class Pipelines < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_pipelines_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                class: 'shortcuts-pipelines'
              }
            end

            override :active_routes
            def active_routes
              { path: ['pipelines#index', 'pipelines#show'] }
            end

            override :item_name
            def item_name
              _('Pipelines')
            end
          end
        end
      end
    end
  end
end
