# frozen_string_literal: true
module EE
  module IssueEntity
    extend ActiveSupport::Concern

    prepended do
      expose :weight, if: ->(issue, _) { issue.weight_available? }

      with_options if: -> (_, options) { options[:with_blocking_issues] } do
        expose :blocked?, as: :blocked

        expose :blocked_by_issues do |issue|
          issues = issue.blocked_by_issues_for(request.current_user)
          serializer_options = options.merge(only: [:iid, :web_url])

          ::IssueEntity.represent(issues, serializer_options)
        end
      end
    end
  end
end
