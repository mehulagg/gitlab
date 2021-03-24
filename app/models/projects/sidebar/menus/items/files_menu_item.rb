# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      module Items
        class FilesMenuItem < ::Sidebar::MenuItem
          def initialize(current_user, project, current_ref)
            super(current_user, project)

            @current_ref = current_ref
          end

          override :link_to_href
          def link_to_href
            project_tree_path(container, @current_ref)
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
