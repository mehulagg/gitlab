# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Settings
          module PipelineSubscriptions
            extend QA::Page::PageConcern

            def self.prepended(base)
              super

              base.class_eval do
                include Page::Component::SecureReport

                view 'ee/app/views/projects/settings/subscriptions/_index.html.haml' do
                  element :upstream_project_path_field
                  element :subscribe_button
                end
              end
            end

            def subscribe(project_path)
              puts "**** PROJECT PATH ****"
              puts project_path

              fill_element(:upstream_project_path_field, project_path)

              sleep 5

              click_element(:subscribe_button)
            end
          end
        end
      end
    end
  end
end
