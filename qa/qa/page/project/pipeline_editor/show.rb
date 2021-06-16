# frozen_string_literal: true

module QA
  module Page
    module Project
      module PipelineEditor
        class Show < QA::Page::Base
          view 'app/assets/javascripts/pipeline_editor/components/file_nav/branch_switcher.vue' do
            element :branch_selector_button
            element :menu_branch_button
          end

          view 'app/assets/javascripts/pipeline_editor/components/commit/commit_form.vue' do
            element :target_branch_field
          end

          def click_branch_selector_button
            click_element(:branch_selector_button, skip_finished_loading_check: true) if has_element?(:branch_selector_button, wait: 2)
          end

          def select_branch_from_dropdown(branch_to_switch_to)
            click_element(:menu_branch_button, text: branch_to_switch_to, skip_finished_loading_check: true) if has_element?(:menu_branch_button, wait: 2)
          end

          def target_branch_name
            find_element(:target_branch_field, skip_finished_loading_check: true).value if has_element?(:target_branch_field, wait: 2)
          end
        end
      end
    end
  end
end
