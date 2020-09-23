# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Settings
          module Repository
            extend QA::Page::PageConcern

            def self.prepended(base)
              super

              base.class_eval do
                view 'ee/app/views/projects/push_rules/_index.html.haml' do
                  element :push_rules_content
                end
              end
            end

            def expand_push_rules(&block)
              expand_content(:push_rules_content) do
                PushRules.perform(&block)
              end
            end
          end
        end
      end
    end
  end
end
