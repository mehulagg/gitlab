# frozen_string_literal: true

module Ci
  class TestCaseFailure < ApplicationRecord
    extend Gitlab::Ci::Model

    REPORT_WINDOW = 14.days

    validates :test_case_id, :build_id, :ref_path, :failed_at, presence: true

    belongs_to :test_case, class_name: "Ci::TestCase", foreign_key: :test_case_id
    belongs_to :build, class_name: "Ci::Build", foreign_key: :build_id

    scope :by_test_cases, -> (project, test_case_keys) { joins(:test_case).where(ci_test_cases: { project_id: project.id, key_hash: test_case_keys }) }

    scope :by_recent_failures_for_ref_path, -> (ref_path, date_range) { where(ref_path: ref_path, failed_at: date_range) }

    scope :group_by_key_hash, -> { group(:key_hash).count('ci_test_case_failures.id') }

    def self.recent_failures_count(project:, test_case_keys:, ref_path:, date_range: REPORT_WINDOW.ago..Time.current)
      by_test_cases(project, test_case_keys)
        .by_recent_failures_for_ref_path(ref_path, date_range)
        .group_by_key_hash
    end
  end
end
