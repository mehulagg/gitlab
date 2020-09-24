# frozen_string_literal: true

class MergeRequestDiffDetail < ApplicationRecord
  self.primary_key = :merge_request_diff_id

  belongs_to :merge_request_diff, inverse_of: :merge_request_diff_detail

  scope :checksummed, -> { where.not(verification_checksum: nil) }
  scope :checksum_failed, -> { where.not(verification_failure: nil) }
end
