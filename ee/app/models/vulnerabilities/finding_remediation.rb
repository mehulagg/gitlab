# frozen_string_literal: true

# This is a join model between the `Finding` and `Remediation` models.
module Vulnerabilities
  class FindingRemediation < ApplicationRecord
    self.table_name = 'vulnerability_finding_remediations'

    belongs_to :finding, optional: false
    belongs_to :remediation, optional: false
  end
end
