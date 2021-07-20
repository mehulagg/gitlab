# frozen_string_literal: true

module EE
  module MergeRequestDiff
    extend ActiveSupport::Concern

    prepended do
      include ::Gitlab::Geo::ReplicableModel
      include ObjectStorable
      include ::Gitlab::Geo::VerificationState

      STORE_COLUMN = :external_diff_store

      with_replicator Geo::MergeRequestDiffReplicator

      has_one :merge_request_diff_detail, autosave: true, inverse_of: :merge_request_diff

      delegate :verification_retry_at, :verification_retry_at=,
               :verified_at, :verified_at=,
               :verification_checksum, :verification_checksum=,
               :verification_failure, :verification_failure=,
               :verification_retry_count, :verification_retry_count=,
               :verification_state=, :verification_state,
               :verification_started_at=, :verification_started_at,
        to: :merge_request_diff_detail, allow_nil: true

      scope :has_external_diffs, -> { with_files.where(stored_externally: true) }
      scope :project_id_in, ->(ids) { where(merge_request_id: ::MergeRequest.where(target_project_id: ids)) }
      scope :available_replicables, -> { has_external_diffs }
      scope :verification_pending, -> { available_verifiables.merge(::MergeRequestDiff.with_verification_state(:verification_pending).or(::MergeRequestDiff.where.missing(:merge_request_diff_detail))) }
      scope :with_verification_state, ->(state) { left_outer_joins(:merge_request_diff_detail).where(merge_request_diff_details: { verification_state: verification_state_value(state) }) }
      scope :checksummed, -> { joins(:merge_request_diff_detail).where.not(merge_request_diff_details: { verification_checksum: nil } ) }
      scope :not_checksummed, -> { joins(:merge_request_diff_detail).where(merge_request_diff_details: { verification_checksum: nil } ) }
    end

    class_methods do
      extend ::Gitlab::Utils::Override

      # @param primary_key_in [Range, MergeRequestDiff] arg to pass to primary_key_in scope
      # @return [ActiveRecord::Relation<MergeRequestDiff>] everything that should be synced to this node, restricted by primary key
      def replicables_for_current_secondary(primary_key_in)
        node = ::Gitlab::Geo.current_node

        available_replicables.primary_key_in(primary_key_in)
                             .merge(selective_sync_scope(node))
                             .merge(object_storage_scope(node))
      end

      override :verification_state_table_name
      def verification_state_table_name
        'merge_request_diff_details'
      end

      override :verification_state_model_key
      def verification_state_model_key
        'merge_request_diff_id'
      end

      override :verification_arel_table
      def verification_arel_table
        MergeRequestDiffDetail.arel_table
      end

      private

      def object_storage_scope(node)
        return all if node.sync_object_storage?

        with_files_stored_locally
      end

      def selective_sync_scope(node)
        return all unless node.selective_sync?

        project_id_in(node.projects)
      end
    end

    def merge_request_diff_detail
      super || build_merge_request_diff_detail
    end

    def log_geo_deleted_event
      # Keep empty for now. Should be addressed in future
      # by https://gitlab.com/gitlab-org/gitlab/issues/33817
    end
  end
end
