# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Settings
          class IssueTemplateDefault < QA::Page::Base
            view 'ee/app/views/projects/settings/_default_issue_template.html.haml' do
              element :issue_template_field
              element :save_issue_template_button
            end

            def set_default_issue_template(template)
              fill_element(:issue_template_field, template)
              click_element(:save_issue_template_button)

              wait_for_requests
            end
          end
        end
      end
    end
  end
end
