# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Analytics
        module MenuItems
          class Issue < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_analytics_issues_analytics_path(context.project)
            end

            override :active_routes
            def active_routes
              { path: 'issues_analytics#show' }
            end

            override :item_name
            def item_name
              _('Issue')
            end

            override :render?
            def render?
              ::Feature.enabled?(:project_level_issues_analytics, context.project, default_enabled: true) &&
                context.project.feature_available?(:issues_analytics) &&
                can?(context.current_user, :read_project, context.project)
            end
          end
        end
      end
    end
  end
end
