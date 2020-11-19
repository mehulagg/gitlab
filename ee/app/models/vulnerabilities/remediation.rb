# frozen_string_literal: true

module Vulnerabilities
  class Remediation < ApplicationRecord
    include FileStoreMounter

    self.table_name = 'vulnerability_remediations'

    has_many :finding_remediations, class_name: 'Vulnerabilities::FindingRemediation', inverse_of: :remediation, foreign_key: 'vulnerability_remediation_id'
    has_many :findings, through: :finding_remediations

    mount_file_store_uploader AttachmentUploader

    validates :summary, presence: true, length: { maximum: 200 }
    validates :file, presence: true
  end
end
