# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Settings
          class Integrations < QA::Page::Base
            view 'app/views/shared/integrations/_integrations.html.haml' do
              element :jenkins_link, '{ data: { qa_selector: "#{integration.to_param' # rubocop:disable QA/ElementWithPattern
            end

            def click_jenkins_ci_link
              click_element :jenkins_link
            end
          end
        end
      end
    end
  end
end
