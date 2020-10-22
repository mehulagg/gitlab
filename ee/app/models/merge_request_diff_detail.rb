# frozen_string_literal: true

class MergeRequestDiffDetail < ApplicationRecord
  self.primary_key = :merge_request_diff_id

  include ::Gitlab::Geo::VerificationState

  belongs_to :merge_request_diff, inverse_of: :merge_request_diff_detail
end
