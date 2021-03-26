# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module CiCd
        module MenuItems
          class TestCases < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_quality_test_cases_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                class: 'shortcuts-test-cases'
              }
            end

            override :nav_link_params
            def nav_link_params
              { controller: :test_cases }
            end

            override :item_name
            def item_name
              _('Test Cases')
            end

            override :render?
            def render?
              context.project.feature_available?(:quality_management) &&
                can?(context.current_user, :read_issue, context.project)
            end
          end
        end
      end
    end
  end
end
