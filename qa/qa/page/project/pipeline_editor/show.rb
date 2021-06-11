# frozen_string_literal: true

module QA
  module Page
    module Project
      module PipelineEditor
        class Show < QA::Page::Base
          view 'app/assets/javascripts/pipeline_editor/components/pipeline_editor_tabs.vue' do
            element :editor_tab
          end

          view 'app/assets/javascripts/pipeline_editor/components/ui/pipeline_editor_empty_state.vue' do
            element :create_new_pipeline_button
          end

          view 'app/assets/javascripts/pipeline_editor/components/editor/text_editor.vue' do
            element :pipeline_editor_textbox
          end

          view 'app/assets/javascripts/pipeline_editor/components/file_nav/branch_switcher.vue' do
            element :branch_selector_button
          end

          def click_create_new_pipeline_button
            click_element(:create_new_pipeline_button)
          end

          def click_pipeline_editor_tab
            click_element(:editor_tab)
          end

          def click_branch_selector_button
            click_element(:branch_selector_button)
          end
        end
      end
    end
  end
end