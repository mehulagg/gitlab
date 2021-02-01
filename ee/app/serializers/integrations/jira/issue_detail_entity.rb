# frozen_string_literal: true

module Integrations
  module Jira
    class IssueDetailEntity < IssueEntity
      expose :description_html do |jira_issue|
        Banzai::Pipeline::GfmPipeline.call(jira_issue.renderedFields['description'], project: nil)[:output].to_html
      end
    end
  end
end
