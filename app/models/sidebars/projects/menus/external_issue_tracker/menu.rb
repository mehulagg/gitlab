# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module ExternalIssueTracker
        class Menu < ::Sidebars::Menu
          override :render?
          def render?
            external_issue_tracker
          end

          override :menu_link
          def menu_link
            external_issue_tracker.issue_tracker_path
          end

          override :extra_menu_container_html_options
          def extra_menu_container_html_options
            {
              target: '_blank',
              rel: 'noopener noreferrer',
              class: 'shortcuts-external_tracker'
            }
          end

          override :menu_name
          def menu_name
            external_issue_tracker.title
          end

          override :menu_name_html_options
          def menu_name_html_options
            {
              id: 'js-onboarding-issues-link'
            }
          end

          override :sprite_icon
          def sprite_icon
            'external-link'
          end

          private

          def external_issue_tracker
            @external_issue_tracker ||= context.project.external_issue_tracker
          end
        end
      end
    end
  end
end

Sidebars::Projects::Menus::ExternalIssueTracker::Menu.prepend_if_ee('EE::Sidebars::Projects::Menus::ExternalIssueTracker::Menu')
