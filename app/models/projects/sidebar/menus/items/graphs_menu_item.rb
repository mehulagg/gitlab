# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      module Items
        class GraphsMenuItem < ::Sidebar::MenuItem
          override :link_to_href
          def link_to_href
            project_network_path(container, current_ref)
          end

          override :nav_link_params
          def nav_link_params
            { controller: :network }
          end

          override :item_name
          def item_name
            _('Graph')
          end
        end
      end
    end
  end
end
