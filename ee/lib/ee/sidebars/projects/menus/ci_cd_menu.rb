# frozen_string_literal: true

module EE
  module Sidebars
    module Projects
      module Menus
        module CiCdMenu
          extend ::Gitlab::Utils::Override

          override :configure_menu_items
          def configure_menu_items
            return false unless super

            add_item(test_cases_menu_item)

            true
          end

          private

          def test_cases_menu_item
            return unless context.project.licensed_feature_available?(:quality_management)
            return unless can?(context.current_user, :read_issue, context.project)

            ::Sidebars::MenuItem.new(
              title: _('Test Cases'),
              link: project_quality_test_cases_path(context.project),
              container_html_options: { class: 'shortcuts-test-cases' },
              active_routes: { controller: :test_cases },
              item_id: :test_cases
            )
          end
        end
      end
    end
  end
end
