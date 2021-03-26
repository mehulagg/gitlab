# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Analytics
        module MenuItems
          class CiCd < ::Sidebars::MenuItem
            override :item_link
            def item_link
              charts_project_pipelines_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                class: 'shortcuts-repository-charts'
              }
            end

            override :active_routes
            def active_routes
              { path: 'pipelines#charts' }
            end

            override :item_name
            def item_name
              _('CI/CD')
            end

            override :render?
            def render?
              context.project.feature_available?(:builds, context.current_user) &&
                can?(context.current_user, :read_build, context.project) &&
                !context.project.empty_repo?
            end
          end
        end
      end
    end
  end
end
