# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      module Items
        class MilestonesMenuItem < ::Sidebar::MenuItem
          override :link_to_href
          def link_to_href
            project_milestones_path(context.project)
          end

          override :link_to_attributes
          def link_to_attributes
            {
              title: _('Milestones'),
              class: 'qa-milestones-link'
            }
          end

          override :nav_link_params
          def nav_link_params
            { controller: :milestones }
          end

          override :item_name
          def item_name
            _('Milestones')
          end
        end
      end
    end
  end
end
