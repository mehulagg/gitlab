# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      module Items
        class ReleasesMenuItem < ::Sidebar::MenuItem
          override :link_to_href
          def link_to_href
            project_releases_path(context.project)
          end

          override :link_to_attributes
          def link_to_attributes
            {
              title: _('Releases'),
              class: 'shortcuts-project-releases'
            }
          end

          override :render?
          def render?
            !context.project.empty_repo? && can?(context.current_user, :read_release, context.project)
          end

          override :nav_link_params
          def nav_link_params
            { controller: :releases }
          end

          override :item_name
          def item_name
            _('Releases')
          end
        end
      end
    end
  end
end
