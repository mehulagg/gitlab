# frozen_string_literal: true

class Geo::MergeRequestDiffRegistry < Geo::BaseRegistry
  include ::Geo::ReplicableRegistry
  include ::Geo::VerifiableRegistry

  MODEL_CLASS = ::MergeRequestDiff
  MODEL_FOREIGN_KEY = :merge_request_diff_id

  self.table_name = 'merge_request_diff_registry'

  belongs_to :merge_request_diff, class_name: 'MergeRequestDiff'
end
