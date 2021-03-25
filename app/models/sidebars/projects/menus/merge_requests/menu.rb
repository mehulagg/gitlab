# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module MergeRequests
        class Menu < ::Sidebars::Menu
          override :link_to_href
          def link_to_href
            project_merge_requests_path(context.project)
          end

          override :link_to_attributes
          def link_to_attributes
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

          override :nav_link_params
          def nav_link_params
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
