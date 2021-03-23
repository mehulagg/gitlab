# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      module Items
        class ReleasesMenuItem < ::Sidebar::MenuItem
          override :link_to_href
          def link_to_href
            project_releases_path(container)
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
            !container.empty_repo? && can?(current_user, :read_release, container)
          end

          override :active_path
          def active_path
            'releases#index'
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
