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

          override :link_to_href
          def link_to_href
            external_issue_tracker.issue_tracker_path
          end

          override :link_to_attributes
          def link_to_attributes
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
