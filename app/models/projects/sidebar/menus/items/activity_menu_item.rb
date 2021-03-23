# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      module Items
        class ActivityMenuItem < ::Sidebar::MenuItem
          override :link_to_href
          def link_to_href
            activity_project_path(container)
          end

          override :link_to_attributes
          def link_to_attributes
            {
              title: _('Activity'),
              class: 'shortcuts-project-activity',
              data: { qa_selector: 'activity_link' }
            }
          end

          override :active_path
          def active_path
            'projects#activity'
          end

          override :item_name
          def item_name
            _('Activity')
          end
        end
      end
    end
  end
end
