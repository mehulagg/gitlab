# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module ProjectMembers
        class Menu < ::Sidebars::Menu
          override :menu_link
          def menu_link
            project_project_members_path(context.project)
          end

          override :extra_menu_container_html_options
          def extra_menu_container_html_options
            {
              class: 'qa-members-link',
              id: 'js-onboarding-members-link'
            }
          end

          override :menu_name
          def menu_name
            _('Members')
          end

          override :active_routes
          def active_routes
            { controller: :project_members }
          end

          override :menu_name_html_options
          def menu_name_html_options
            {
              data: { qa_selector: 'analytics_link' }
            }
          end

          override :sprite_icon
          def sprite_icon
            'users'
          end

          override :render?
          def render?
            can?(context.current_user, :read_snippet, context.project)
          end
        end
      end
    end
  end
end

# = nav_link(controller: :project_members) do
#   = link_to project_project_members_path(@project), title: _('Members'), class: 'qa-members-link', id: 'js-onboarding-members-link' do
#     .nav-icon-container
#       = sprite_icon('users')
#     %span.nav-item-name
#       = _('Members')
#   %ul.sidebar-sub-level-items.is-fly-out-only
#     = nav_link(path: %w[members#show], html_options: { class: "fly-out-top-item" } ) do
#       = link_to project_project_members_path(@project) do
#         %strong.fly-out-top-item-name
#           = _('Members')
