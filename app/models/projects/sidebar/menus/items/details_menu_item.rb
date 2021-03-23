# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      module Items
        class DetailsMenuItem < ::Sidebar::MenuItem
          override :link_to_href
          def link_to_href
            project_path(container)
          end

          override :link_to_attributes
          def link_to_attributes
            {
              title: _('Project details'),
              class: 'shortcuts-project'
            }
          end

          override :active_path
          def active_path
            'projects#show'
          end

          override :item_name
          def item_name
            _('Details')
          end
        end
      end
    end
  end
end
