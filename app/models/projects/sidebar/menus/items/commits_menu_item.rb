# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      module Items
        class CommitsMenuItem < ::Sidebar::MenuItem
          def initialize(current_user, project, current_ref)
            super(current_user, project)

            @current_ref = current_ref
          end

          override :link_to_href
          def link_to_href
            project_commits_path(container, @current_ref)
          end

          override :link_to_attributes
          def link_to_attributes
            {
              id: 'js-onboarding-commits-link'
            }
          end

          override :nav_link_params
          def nav_link_params
            { controller: %w(commit commits) }
          end

          override :item_name
          def item_name
            _('Commits')
          end
        end
      end
    end
  end
end
