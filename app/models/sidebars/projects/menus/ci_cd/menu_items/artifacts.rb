# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module CiCd
        module MenuItems
          class Artifacts < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_artifacts_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                class: 'shortcuts-builds'
              }
            end

            override :nav_link_params
            def nav_link_params
              { path: 'artifacts#index' }
            end

            override :item_name
            def item_name
              _('Artifacts')
            end

            override :render?
            def render?
              Feature.enabled?(:artifacts_management_page, context.project)
            end
          end
        end
      end
    end
  end
end
