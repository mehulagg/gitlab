# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Monitoring
        module MenuItems
          class FeatureFlags < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_feature_flags_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                class: 'shortcuts-feature-flags'
              }
            end

            override :active_routes
            def active_routes
              { controller: :feature_flags }
            end

            override :item_name
            def item_name
              _('Feature Flags')
            end

            override :render?
            def render?
              can?(context.current_user, :read_feature_flag, context.project)
            end
          end
        end
      end
    end
  end
end
