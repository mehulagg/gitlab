# frozen_string_literal: true

module Geo
  class FileRegistryFinder < RegistryFinder
    # @!method synced_missing_on_primary_count
    #    Return a count of the registry records for the tracked file_type(s)
    #    that are synced and missing on the primary
    def synced_missing_on_primary_count
      registry_class.synced.missing_on_primary.count
    end

    # @!method find_retryable_synced_missing_on_primary_registries
    #    Return an ActiveRecord::Relation of registry records marked as synced
    #    and missing on the primary, which are ready to be retried, excluding
    #    specified IDs, limited to batch_size
    #
    # @param [Integer] batch_size used to limit the results returned
    # @param [Array<Integer>] except_ids ids that will be ignored from the query
    #
    # rubocop:disable CodeReuse/ActiveRecord
    def find_retryable_synced_missing_on_primary_registries(batch_size:, except_ids: [])
      registry_class
        .synced
        .missing_on_primary
        .retry_due
        .model_id_not_in(except_ids)
        .limit(batch_size)
    end
    # rubocop:enable CodeReuse/ActiveRecord
  end
end
