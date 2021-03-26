# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Repository
        module MenuItems
          class Files < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_tree_path(context.project, context.current_ref)
            end

            override :nav_link_params
            def nav_link_params
              { controller: %w(tree blob blame edit_tree new_tree find_file) }
            end

            override :item_name
            def item_name
              _('Files')
            end
          end
        end
      end
    end
  end
end
