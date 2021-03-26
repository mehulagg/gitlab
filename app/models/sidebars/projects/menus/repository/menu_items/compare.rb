# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Repository
        module MenuItems
          class Compare < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_compare_index_path(context.project, from: context.project.repository.root_ref, to: context.current_ref)
            end

            override :active_routes
            def active_routes
              { controller: :compare }
            end

            override :item_name
            def item_name
              _('Compare')
            end
          end
        end
      end
    end
  end
end
