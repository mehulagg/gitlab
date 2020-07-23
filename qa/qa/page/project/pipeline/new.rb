# frozen_string_literal: true

module QA
  module Page
    module Project
      module Pipeline
        class New < QA::Page::Base
          view 'app/assets/javascripts/pipeline_new/components/pipeline_new_form.vue' do
            element :run_pipeline_button
            element :danger_alert_content
          end

          def click_run_pipeline_button
            click_element :run_pipeline_button
          end

          def has_danger_alert?
            has_element? :danger_alert_content
          end
        end
      end
    end
  end
end
