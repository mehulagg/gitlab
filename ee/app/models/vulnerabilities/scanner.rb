# frozen_string_literal: true

module Vulnerabilities
  class Scanner < ApplicationRecord
    self.table_name = "vulnerability_scanners"

    has_many :findings, class_name: 'Vulnerabilities::Finding', inverse_of: :scanner
    has_many :security_findings, class_name: 'Security::Finding', inverse_of: :scanner

    belongs_to :project

    validates :project, presence: true
    validates :external_id, presence: true, uniqueness: { scope: :project_id }
    validates :name, presence: true
    validates :vendor, length: { maximum: 255, allow_nil: false }

    scope :with_external_id, -> (external_ids) { where(external_id: external_ids) }

    scope :for_projects, -> (project_ids) { where(project_id: project_ids) }
    scope :with_report_type, -> do
      joins(:findings)
        .select('DISTINCT ON ("vulnerability_scanners"."external_id", "vulnerability_occurrences"."report_type") "vulnerability_scanners".*, "vulnerability_occurrences"."report_type" AS "report_type"')
        .order('"vulnerability_scanners"."external_id" ASC, "vulnerability_occurrences"."report_type" ASC')
    end
  end
end
