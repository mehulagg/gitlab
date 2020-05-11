# frozen_string_literal: true

module QA
  module Page
    module Dashboard
      module Snippet
        class Show < Page::Base
          view 'app/assets/javascripts/snippets/components/snippet_description_view.vue' do
            element :snippet_description_field
          end

          view 'app/assets/javascripts/snippets/components/snippet_title.vue' do
            element :snippet_title, required: true
          end

          view 'app/views/shared/snippets/_header.html.haml' do
            element :snippet_title, required: true
            element :snippet_description_field, required: true
            element :snippet_box
          end

          view 'app/views/projects/blob/_header_content.html.haml' do
            element :file_title_name
          end

          view 'app/assets/javascripts/blob/components/blob_header_filepath.vue' do
            element :file_title_name
          end

          view 'app/views/shared/_file_highlight.html.haml' do
            element :file_content
          end

          view 'app/assets/javascripts/vue_shared/components/blob_viewers/simple_viewer.vue' do
            element :file_content
          end

          def has_snippet_title?(snippet_title)
            has_element? :snippet_title, text: snippet_title
          end

          def has_snippet_description?(snippet_description)
            has_element? :snippet_description_field, text: snippet_description
          end

          def has_visibility_type?(visibility_type)
            within_element(:snippet_box) do
              has_text?(visibility_type)
            end
          end

          def has_file_name?(file_name)
            within_element(:file_title_name) do
              has_text?(file_name)
            end
          end

          def has_file_content?(file_content)
            finished_loading?
            within_element(:file_content) do
              has_text?(file_content)
            end
          end
        end
      end
    end
  end
end
