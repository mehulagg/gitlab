# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module CiCd
        module MenuItems
          class Pipelines < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              project_pipelines_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: item_name,
                class: 'shortcuts-pipelines'
              }
            end

            override :nav_link_params
            def nav_link_params
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
