# frozen_string_literal: true

class MergeRequestDiffDetail < ApplicationRecord
  self.primary_key = :merge_request_diff_id

  belongs_to :merge_request_diff, inverse_of: :merge_request_diff_detail

  # Temporarily defining `verification_success` and `verification_failed`
  # for unverified models while verification is under development to avoid
  # breaking GeoNodeStatusCheck code.
  # Remove these after including `Gitlab::Geo::VerificationState` on this model.
  scope :verification_success, -> { none }
  scope :verification_failed, -> { none }
end
