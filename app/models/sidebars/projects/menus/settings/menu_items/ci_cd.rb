# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Settings
        module MenuItems
          class CiCd < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_settings_ci_cd_path(context.project)
            end

            override :active_routes
            def active_routes
              { controller: :ci_cd }
            end

            override :item_name
            def item_name
              _('CI/CD')
            end

            override :render?
            def render?
              !context.project.archived? && context.project.feature_available?(:builds, context.current_user)
            end
          end
        end
      end
    end
  end
end
