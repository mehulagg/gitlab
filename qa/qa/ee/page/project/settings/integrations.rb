# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Settings
          module Integrations
            extend QA::Page::PageConcern

            def self.prepended(base)
              base.class_eval do
                view 'app/views/shared/integrations/_index.html.haml' do
                  element :jenkins_link, '{ data: { qa_selector: "#{integration.to_param' # rubocop:disable QA/ElementWithPattern
                end
              end
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
