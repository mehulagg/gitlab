# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Repository
        module MenuItems
          class Files < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              project_tree_path(context.project, context.current_ref)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: _('Files')
              }
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
