# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Repository
        module MenuItems
          class Graphs < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_network_path(context.project, context.current_ref)
            end

            override :active_routes
            def active_routes
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
end
