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
                view 'app/assets/javascripts/integrations/index/components/integrations_table.vue' do
                  element :jenkins_link, %q(:data-qa-selector="`${item.name}_link`") # rubocop:disable QA/ElementWithPattern
                  element :jira_link, %q(:data-qa-selector="`${item.name}_link`") # rubocop:disable QA/ElementWithPattern
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
