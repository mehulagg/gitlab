# frozen_string_literal: true

module Vulnerabilities
  class Remediation < ApplicationRecord
    self.table_name = 'vulnerability_remediations'

    has_many :finding_remediations
    has_many :findings, through: :finding_remediations

    validates :summary, presence: true, length: { maximum: 200 }
    validates :diff, presence: true, length: { maximum: 1_000_000 }
  end
end
