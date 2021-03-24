# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      module Items
        class BoardsMenuItem < ::Sidebar::MenuItem
          override :link_to_href
          def link_to_href
            project_boards_path(context.project)
          end

          override :link_to_attributes
          def link_to_attributes
            {
              title: item_name,
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
