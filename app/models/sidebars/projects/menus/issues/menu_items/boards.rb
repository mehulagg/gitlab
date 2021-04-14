# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Issues
        module MenuItems
          class Boards < ::Sidebars::MenuItem
            override :link
            def link
              project_boards_path(context.project)
            end

            override :extra_container_html_options
            def extra_container_html_options
              {
                data: { qa_selector: 'issue_boards_link' }
              }
            end

            override :active_routes
            def active_routes
              { controller: :boards }
            end

            override :title
            def title
              boards_link_text
            end

            private

            def boards_link_text
              @boards_link_text ||= begin
                if context.project.multiple_issue_boards_available?
                  s_('IssueBoards|Boards')
                else
                  s_('IssueBoards|Board')
                end
              end
            end
          end
        end
      end
    end
  end
end
