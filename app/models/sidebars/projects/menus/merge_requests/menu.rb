# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module MergeRequests
        class Menu < ::Sidebars::Menu
          override :menu_link
          def menu_link
            project_merge_requests_path(context.project)
          end

          override :extra_menu_container_html_options
          def extra_menu_container_html_options
            {
              class: 'shortcuts-merge_requests',
              data: { qa_selector: 'merge_requests_link' }
            }
          end

          override :menu_name
          def menu_name
            _('Merge Requests')
          end

          override :menu_name_html_options
          def menu_name_html_options
            {
              id: 'js-onboarding-mr-link'
            }
          end

          override :sprite_icon
          def sprite_icon
            'git-merge'
          end

          override :render?
          def render?
            context.project.repo_exists? && can?(context.current_user, :read_merge_request, context.project)
          end

          override :has_pill?
          def has_pill?
            true
          end

          override :pill_count
          def pill_count
            @pill_count ||= context.project.open_merge_requests_count
          end

          override :pill_html_options
          def pill_html_options
            {
              class: 'merge_counter js-merge-counter'
            }
          end

          override :active_routes
          def active_routes
            if context.project.issues_enabled?
              { controller: :merge_requests }
            else
              { controller: [:merge_requests, :milestones] }
            end
          end
        end
      end
    end
  end
end
