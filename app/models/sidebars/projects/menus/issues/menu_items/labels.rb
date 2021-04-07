# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Issues
        module MenuItems
          class Labels < ::Sidebars::MenuItem
            override :link
            def link
              project_labels_path(context.project)
            end

            override :active_routes
            def active_routes
              { controller: :labels }
            end

            override :title
            def title
              _('Labels')
            end
          end
        end
      end
    end
  end
end
