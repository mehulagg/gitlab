# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Issues
        module MenuItems
          class Boards < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_boards_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                data: { qa_selector: "issue_boards_link" }
              }
            end

            override :nav_link_params
            def nav_link_params
              { controller: :boards }
            end

            override :item_name
            def item_name
              boards_link_text
            end

            private

            def boards_link_text
              @boards_link_text ||= begin
                if context.project.multiple_issue_boards_available?
                  s_("IssueBoards|Boards")
                else
                  s_("IssueBoards|Board")
                end
              end
            end
          end
        end
      end
    end
  end
end
