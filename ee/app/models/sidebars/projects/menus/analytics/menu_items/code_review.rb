# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Analytics
        module MenuItems
          class CodeReview < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_analytics_code_reviews_path(context.project)
            end

            override :active_routes
            def active_routes
              { path: 'projects/analytics/code_reviews#index' }
            end

            override :item_name
            def item_name
              _('Code Review')
            end

            override :render?
            def render?
              can?(context.current_user, :read_code_review_analytics, context.project)
            end
          end
        end
      end
    end
  end
end
