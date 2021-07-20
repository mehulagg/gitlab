# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Settings
          class PipelineSubscriptions < QA::Page::Base
            view 'ee/app/views/projects/settings/subscriptions/_index.html.haml' do
              element :upstream_project_path_field
              element :subscribe_button
            end

            def subscribe(project_path)
              fill_element(:upstream_project_path_field, project_path)
              click_element(:subscribe_button)
            end
          end
        end
      end
    end
  end
end
