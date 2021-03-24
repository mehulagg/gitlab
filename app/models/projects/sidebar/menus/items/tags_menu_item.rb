# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      module Items
        class TagsMenuItem < ::Sidebar::MenuItem
          override :link_to_href
          def link_to_href
            project_tags_path(context.project)
          end

          override :link_to_attributes
          def link_to_attributes
            {
              data: { qa_selector: 'tags_link' }
            }
          end

          override :nav_link_params
          def nav_link_params
            { controller: :tags }
          end

          override :item_name
          def item_name
            _('Tags')
          end
        end
      end
    end
  end
end
