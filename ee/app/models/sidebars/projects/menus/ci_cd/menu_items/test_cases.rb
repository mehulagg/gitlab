# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module CiCd
        module MenuItems
          class TestCases < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              project_quality_test_cases_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: item_name,
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
