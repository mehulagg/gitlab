# frozen_string_literal: true

module QA
  module Page
    module Project
      module PipelineEditor
        class Show < QA::Page::Base
          view 'app/assets/javascripts/pipeline_editor/components/pipeline_editor_tabs.vue' do
            element :editor_tab
            element :visualization_tab
            element :lint_tab
            element :merged_tab
          end

          view 'app/assets/javascripts/pipeline_editor/components/ui/pipeline_editor_empty_state.vue' do
            element :create_new_pipeline_button
          end

          view 'app/assets/javascripts/pipeline_editor/components/editor/text_editor.vue' do
            element :pipeline_editor_textbox
          end
        end
      end
    end
  end
end
