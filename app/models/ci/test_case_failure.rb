# frozen_string_literal: true

module Ci
  class TestCaseFailure < ApplicationRecord
    extend Gitlab::Ci::Model

    REPORT_WINDOW = 14.days

    belongs_to :test_case, class_name: "Ci::TestCase", foreign_key: :test_case_id
    belongs_to :build, class_name: "Ci::Build", foreign_key: :build_id

    def self.recent_failures_count(project, test_case_keys)
      now = Time.zone.now
      from = now - REPORT_WINDOW

      joins(:test_case).where(
        ci_test_cases: {
          project_id: project.id,
          key_hash: test_case_keys
        },
        ci_test_case_failures: {
          failed_at: from..now
        }
      ).group(:key_hash).count("ci_test_case_failures.id")
    end
  end
end
