# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      module Items
        class ContributorsMenuItem < ::Sidebar::MenuItem
          override :link_to_href
          def link_to_href
            project_graph_path(container, current_ref)
          end

          override :nav_link_params
          def nav_link_params
            { path: 'graphs#show' }
          end

          override :item_name
          def item_name
            _('Contributors')
          end
        end
      end
    end
  end
end
