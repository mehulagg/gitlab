# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Analytics
        module MenuItems
          class MergeRequest < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_analytics_merge_request_analytics_path(context.project)
            end

            override :active_routes
            def active_routes
              { path: 'projects/analytics/merge_request_analytics#show' }
            end

            override :item_name
            def item_name
              _('Merge Request')
            end

            override :render?
            def render?
              can?(context.current_user, :read_project_merge_request_analytics, context.project)
            end
          end
        end
      end
    end
  end
end
