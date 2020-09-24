# frozen_string_literal: true

module QA
  module EE
    module Page
      module Group
        class ContributionAnalytics < QA::Page::Base
          view 'ee/app/views/groups/contribution_analytics/show.html.haml' do
            element :push_content
            element :merge_request_content
            element :issue_content
          end

          def has_push_element?(text)
            has_element? :push_content, text: text
          end

          def has_mr_element?(text)
            has_element? :merge_request_content, text: text
          end

          def has_issue_element?(text)
            has_element? :issue_content, text: text
          end
        end
      end
    end
  end
end
