# frozen_string_literal: true

module EE
  module ActsLikeRequirement
    has_many :test_reports, foreign_key: :issue_id, inverse_of: :requirement_issue, class_name: 'RequirementsManagement::TestReport'
  end
end
