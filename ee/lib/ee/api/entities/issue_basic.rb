# frozen_string_literal: true

module EE
  module API
    module Entities
      module IssueBasic
        extend ActiveSupport::Concern

        prepended do
          expose :weight, if: ->(issue, _) { issue.weight_available? }

          expose(:blocking_issues_count) do |issue, options|
            issuable_metadata.blocking_issues_count
          end
        end
      end
    end
  end
end
