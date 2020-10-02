# frozen_string_literal: true

module QA
  module Page
    module Component
      module SnippetIndex
        extend QA::Page::PageConcern

        def self.included(base)
          super

          base.view 'app/views/layouts/header/_new_dropdown.haml' do
            element :new_menu_toggle
            element :global_new_snippet_link
          end

          base.view 'app/views/shared/snippets/_snippet.html.haml' do
            element :snippet_link
          end
        end

        def go_to_new_snippet_page
          click_element :new_menu_toggle
          click_element :global_new_snippet_link
        end

        def has_snippet?(title)
          has_element?(:snippet_link, snippet_title: title)
        end

        def click_snippet_link(title)
          within_element(:snippet_link, text: title) do
            click_link(title)
          end
        end
      end
    end
  end
end
