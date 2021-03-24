# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      module Items
        class CompareMenuItem < ::Sidebar::MenuItem
          override :link_to_href
          def link_to_href
            project_compare_index_path(context.project, from: context.project.repository.root_ref, to: context.current_ref)
          end

          override :nav_link_params
          def nav_link_params
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
