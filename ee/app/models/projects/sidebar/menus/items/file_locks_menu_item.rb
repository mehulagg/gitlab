# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      module Items
        class FileLocksMenuItem < ::Sidebar::MenuItem
          override :link_to_href
          def link_to_href
            project_path_locks_path(context.project)
          end

          override :link_to_attributes
          def link_to_attributes
            {
              data: { qa_selector: 'path_locks_link' }
            }
          end

          override :nav_link_params
          def nav_link_params
            { controller: :path_locks }
          end

          override :item_name
          def item_name
            _('Locked Files')
          end

          override :render?
          def render?
            context.project.feature_available?(:file_locks)
          end
        end
      end
    end
  end
end
