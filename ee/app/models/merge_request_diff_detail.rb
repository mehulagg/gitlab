# frozen_string_literal: true

class MergeRequestDiffDetail < ApplicationRecord
  self.primary_key = :merge_request_diff_id

  belongs_to :merge_request_diff, inverse_of: :merge_request_diff_detail

  # Temporarily defining `verification_succeeded` and
  # `verification_failed` for unverified models while verification is
  # under development to avoid breaking GeoNodeStatusCheck code.
  # TODO: Remove these after including `Gitlab::Geo::VerificationState` on
  # all models. https://gitlab.com/gitlab-org/gitlab/-/issues/280768
  scope :verification_succeeded, -> { none }
  scope :verification_failed, -> { none }
end
